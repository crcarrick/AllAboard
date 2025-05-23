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

        do {
            guard await ensurePermission() else {
                Log.notifier.debug("Tried to send notification but permissions were not granted yet")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "🚂 Time to show your ticket!"
            content.body  = "You have \(prs.count) PR(s) ready to merge."
            content.sound = .default
            content.categoryIdentifier = "READY_PRS"

            Log.notifier.debug("Sending notification for \(prs.count) PR(s)")
            
            try await center.add(
                UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            )
        } catch {
            Log.notifier.info("Error sending notification: \(error)")
            return
        }
    }
    
    func sendNotification() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            guard await ensurePermission() else {
                Log.notifier.debug("Tried to send notification but permissions were not granted yet")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "🚀 All clear!"
            content.body  = "You have no PRs ready to merge."
            content.sound = .default

            Log.notifier.debug("Sending notification for no PRs")
            
            try await center.add(
                UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            )
        } catch {
            Log.notifier.warning("Error sending notification: \(error)")
            return
        }
    }
    
    private func ensurePermission(retries: Int = 5, initialDelay: TimeInterval = 0.5, backoffFactor: Double = 1.5) async -> Bool {
        var delay = initialDelay
        
        for attempt in 1...retries {
            Log.notifier.debug("Checking notification permission (attempt \(attempt))")
            
            let settings = await withCheckedContinuation { continuation in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    continuation.resume(returning: settings)
                }
            }
            
            if settings.authorizationStatus == .authorized {
                Log.notifier.debug("Notification permission granted (attempt \(attempt))")
                return true
            }
            
            Log.notifier.debug("Notification permission not granted yet (attempt \(attempt)), retrying in \(delay) seconds...")
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            delay *= backoffFactor
        }
        
        Log.notifier.warning("Notification permission not granted after \(retries) attempts")
        return false
    }
}
