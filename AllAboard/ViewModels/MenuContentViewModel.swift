//
//  MenuContentViewModel.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/23/25.
//

import SwiftUI

protocol MenuContentViewModelProtocol: ObservableObject {
    func checkPRsNow()
    func viewSettings()
    func quit()
}

class MenuContentViewModel: ObservableObject, MenuContentViewModelProtocol {
    @Environment(\.openSettings) private var openSettings
    
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
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}

final class MockMenuContentViewModel: MenuContentViewModelProtocol {
    func checkPRsNow() {
        print("Mock checkPRsNow")
    }
    
    func viewSettings() {
        print("Mock viewSettings")
    }
    
    func quit() {
        print("Mock quit")
    }
}
