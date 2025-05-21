//
//  AllAboardApp.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import SwiftUI
import UserNotifications
import OctoKit

@main
struct AllAboardApp: App {
    @Environment(\.openSettings) private var openSettings
    
    var body: some Scene {
        MenuBarExtra("Deploy Train", systemImage: "train.side.front.car") {
            MenuContentView()
        }
        
        Settings {
            PreferencesView()
        }
    }
    
    init() {
        ScheduleService.shared.start()
    }
}
