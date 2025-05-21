//
//  NotificationDelegate.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/21/25.
//

import AppKit
import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func register() {
        let center = UNUserNotificationCenter.current()
        center.delegate = NotificationDelegate.shared
        
        let action = UNNotificationAction(
            identifier: "OPEN_GITHUB",
            title: "View PRs",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "READY_PRS",
            actions: [action],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories(Set([category]))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        
        guard response.actionIdentifier == "OPEN_GITHUB" else { return }
        
        let ghUser = response.notification.request.content.userInfo["ghUser"] as? String
        let authorQuery = ghUser.map { "author:\($0)" } ?? ""
        
        var components = URLComponents()
        components.host = "github.com"
        components.path = "/klaviyo/app/pulls"
        components.scheme = "https"
        components.queryItems = [
            URLQueryItem(name: "q", value: "is:open label:ready-to-merge \(authorQuery)")
        ]
        
        if let url = components.url {
            NSWorkspace.shared.open(url)
        }
    }
}
