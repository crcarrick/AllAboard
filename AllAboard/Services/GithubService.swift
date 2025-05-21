//
//  GithubService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import OctoKit

class GithubService {
    static let shared = GithubService()
    
    func checkForReadyPRs(completion: @escaping ([String]) -> Void) {
        guard let token = GithubTokenStore.loadToken() else {
            completion([])
            return
        }
        
        let config = TokenConfiguration(token)
        let octokit = Octokit(config)
        
        octokit.me() { response in
            switch response {
            case .success(let user):
                let id = user.id
                
                self.fetchAllPRs { prs in
                    let filtered = prs.filter { $0.user?.id == id && $0.labels?.contains(where: { $0.name == "ready-to-merge" }) ?? false }
                    
                    if filtered.isEmpty {
                        completion([])
                    } else {
                        completion(filtered.map({ $0.title ?? "" }))
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                completion([])
            }
        }
    }
    
    private func fetchAllPRs(page: Int = 1, collected: [PullRequest] = [], completion: @escaping ([PullRequest]) -> Void) {
        guard let token = GithubTokenStore.loadToken() else {
            completion([])
            return
        }
        
        let config = TokenConfiguration(token)
        let octokit = Octokit(config)
        
        octokit.pullRequests(owner: "klaviyo", repository: "app", page: String(page), perPage: "100") { response in
            switch response {
            case .success(let prs):
                let allPRs = collected + prs
                
                if prs.count == 100 {
                    self.fetchAllPRs(page: page + 1, collected: allPRs, completion: completion)
                } else {
                    completion(allPRs)
                }
            case .failure(let error):
                print("Pagination failed: \(error)")
                completion(collected)
            }
        }
    }
}
