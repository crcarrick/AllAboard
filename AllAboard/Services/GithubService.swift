//
//  GithubService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import OctoKit

class GithubService {
    static let shared = GithubService()
    
    private let repo = "app"
    private let owner = "klaviyo"
    private let label = "ready-to-merge"
    private var cachedUser: User? = nil
    
    private var ghClient: Octokit? {
        guard let token = GithubTokenStore.loadToken() else {
            return nil
        }
        
        return Octokit(TokenConfiguration(token))
    }
    
    func getReadyPRs() async -> [String] {
        guard let client = ghClient else {
            return []
        }
        

        if let user = await me(client: client) {
            let prs = await fetchPRs(client: client)
            
            return prs.filter({$0.user?.id == user.id && $0.labels?.contains(where: { $0.name == label }) == true})
                .compactMap(\.title)
        }
        
        return []
    }
    
    private func me(client: Octokit) async -> User? {
        if let cachedUser {
            return cachedUser
        }
        
        do {
            let user = try await client.me()
            cachedUser = user
            return user
        } catch {
            print("Failed to fetch Github user: \(error)")
            return nil
        }
    }
    
    private func fetchPRs(client: Octokit, page: Int = 1, collected: [PullRequest] = []) async -> [PullRequest] {
        do {
            let prs = try await client.pullRequests(owner: owner, repository: repo, page: String(page), perPage: "100")
            
        return prs.count >= 100
            ? await self.fetchPRs(client: client, page: page + 1, collected: collected + prs)
            : collected + prs
        } catch {
            print("Github PR fetch failed: \(error)")
            return collected
        }
    }
}
