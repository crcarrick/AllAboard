//
//  NotificationPermissionManager.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/23/25.
//

import SwiftUI
import UserNotifications

@MainActor
final class NotificationPermissionManager: ObservableObject {
    @AppStorage("hasSeenNotificationPermissionPrompt") var hasSeenNotificationPermissionPrompt: Bool = false
    
    private let promptManager = NotificationPromptManager()
    
    func check() {
        Log.notifier.debug("Has seen notification permission prompt: \(hasSeenNotificationPermissionPrompt)")
        
        guard !hasSeenNotificationPermissionPrompt else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Log.notifier.debug("Showing notification permission prompt")
            
            self.promptManager.showNotificationPrompt() { accepted in
                if accepted {
                    self.userAccepted()
                } else {
                    self.userRejected()
                }
            }
        }
    }
    
    func userAccepted() {
        hasSeenNotificationPermissionPrompt = true
        requestPermission()
    }
    
    func userRejected() {
        hasSeenNotificationPermissionPrompt = true
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                Log.notifier.warning("Notification permission error: \(error)")
            }
            Log.notifier.info("Notification permission granted: \(granted)")
        }
    }
}
