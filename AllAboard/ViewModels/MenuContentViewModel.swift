//
//  MenuContentViewModel.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/23/25.
//

import SwiftUI
import UserNotifications

@MainActor
protocol MenuContentViewModelProtocol: ObservableObject {
    var notificationStatus: UNAuthorizationStatus { get set }
    
    func checkNotificationStatus()
    func checkPRsNow()
    func viewSettings()
    func viewNotifications()
    func quit()
}

class MenuContentViewModel: ObservableObject, MenuContentViewModelProtocol {
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    private let openSettings: OpenSettingsAction
    
    init(openSettings: OpenSettingsAction) {
        self.openSettings = openSettings
    }
    
    func checkPRsNow() {
        Task {
            let prs = await GithubService.shared.getReadyPRs()
            if !prs.isEmpty {
                await NotificationService.shared.sendNotification(for: prs)
            } else {
                await NotificationService.shared.sendNotification()
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }
    
    func viewSettings() {
        NSApp.activate()
        
        if let settingsWindow = NSApp.windows.first(where: {
            $0.identifier?.rawValue == "com.apple.SwiftUI.Settings" &&
            $0.title == "AllAboard Settings"
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                settingsWindow.makeKeyAndOrderFront(nil)
            }
        } else {
            openSettings()
        }
    }
    
    func viewNotifications() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}

@MainActor
final class MockMenuContentViewModel: MenuContentViewModelProtocol {
    var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    func checkPRsNow() {
        print("Mock checkPRsNow")
    }
    
    func checkNotificationStatus() {
        print("Mock checkNotificationStatus")
    }
    
    func viewSettings() {
        print("Mock viewSettings")
    }
    
    func viewNotifications() {
        print("Mock viewNotifications")
    }
    
    func quit() {
        print("Mock quit")
    }
}
