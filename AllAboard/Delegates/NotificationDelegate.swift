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
            identifier: "OPEN_SLACK",
            title: "View in Slack",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "DEPLOY_NOTIFICATIONS",
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
        
        guard response.actionIdentifier == "OPEN_SLACK" else { return }
        
        if let url = URL(string: "https://klaviyo.enterprise.slack.com/archives/C07MBNK8V") {
            Log.notifier.debug("Opening Slack URL: \(url)")
            NSWorkspace.shared.open(url)
        }
    }
}
