//
//  NotificationService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func sendNotification(for prs: [String]) async {
        let center = UNUserNotificationCenter.current()
        let ghUser = await GithubService.shared.me()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "🚂 Time to show your ticket!"
                content.body  = "You have \(prs.count) PR(s) ready to merge."
                content.sound = .default
                content.userInfo = ["ghUser": ghUser?.login ?? ""]
                content.categoryIdentifier = "READY_PRS"

                try await center.add(
                    UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                )
            }
        } catch {
            print("Error sending notification: \(error)")
            return
        }
    }
    
    func sendNotification() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "🚀 All clear!"
                content.body  = "You have no PRs ready to merge."
                content.sound = .default

                try await center.add(
                    UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                )
            }
        } catch {
            print("Error sending notification: \(error)")
            return
        }
    }
}
