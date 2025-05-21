//
//  GithubTokenStore.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import Foundation
import Security

class GithubTokenStore {
    private static let service = "AllAboard"
    private static let account = "GithubToken"
    
    static func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
        ]
        
        var result: CFTypeRef?
        
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        
        return token
    }
    
    static func saveToken(_ token: String) {
        deleteToken()
        
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
