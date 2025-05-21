//
//  NotificationService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func sendNotification(for prs: [String]) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "🚂 Time to show your ticket!"
                content.body  = "You have \(prs.count) PR(s) ready to merge."
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                
                center.add(request)
            }
        }
    }
}
