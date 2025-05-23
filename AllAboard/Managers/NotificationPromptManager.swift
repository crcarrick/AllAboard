//
//  NotificationPromptManager.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/23/25.
//

import AppKit
import SwiftUI

@MainActor
final class NotificationPromptManager {
    private var window: NSWindow?
    
    func showNotificationPrompt(_ action: @escaping (Bool) -> Void) {
        let view = NotificationPromptView() { accepted in
            action(accepted)
            self.close()
        }
        
        self.window = makeWindow(view: view)
    }
    
    private func close() {
        window?.close()
        window = nil
    }
    
    private func makeWindow(view: some View) -> NSWindow {
        let hostingController = NSHostingController(rootView: view)
        let win = NSWindow(contentViewController: hostingController)
        
        win.title = "All Aboard"
        win.setContentSize(NSSize(width: 360, height: 240))
        win.styleMask = [.titled, .closable]
        win.isReleasedWhenClosed = false
        win.center()
        win.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
        
        return win
    }
}
