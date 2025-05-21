//
//  MenuContentView.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/21/25.
//

import SwiftUI

struct MenuContentView: View {
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        VStack {
            Button("Check PRs Now") {
                GithubService.shared.checkForReadyPRs { prs in
                    if !prs.isEmpty {
                        NotificationService.shared.sendNotification(for: prs)
                    }
                }
            }
            .keyboardShortcut("r")
            
            Divider()
            
            Button("Settings") {
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
            .keyboardShortcut(",")
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}

#Preview {
    // TODO: Doesn't look at all like the real menu bar
    MenuContentView()
        .padding()
}
