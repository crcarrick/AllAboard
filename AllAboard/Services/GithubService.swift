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
            
            Log.requests.debug("Found \(prs.count) PRs")
            
            let filtered = prs.filter({$0.user?.id == user.id && $0.labels?.contains(where: { $0.name == label }) == true})
                .compactMap(\.title)
            
            Log.requests.debug("Found \(filtered.count) ready PRs")
            
            return filtered
        }
        
        return []
    }
    
    func me(client: Octokit? = nil) async -> User? {
        do {
            if let client {
                return try await client.me()
            }
            
            return try await ghClient?.me()
        } catch {
            Log.requests.warning("Github me request failed: \(error)")
            return nil
        }
    }
    
    private func fetchPRs(client: Octokit,
                          page: Int = 1,
                          collected: [PullRequest] = []) async -> [PullRequest] {
        do {
            let prs = try await client.pullRequests(owner: owner, repository: repo, page: String(page), perPage: "100")
            
            return prs.count >= 100
                ? await self.fetchPRs(client: client, page: page + 1, collected: collected + prs)
                : collected + prs
        } catch {
            Log.requests.warning("Github PR fetch failed: \(error)")
            return collected
        }
    }
}
