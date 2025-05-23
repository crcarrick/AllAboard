//
//  NotificationPromptView.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/23/25.
//

import SwiftUI

struct NotificationPromptView: View {
    @StateObject private var permissionManager = NotificationPermissionManager()
    
    let action: (_ accepted: Bool) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .shadow(radius: 4)
            
            Text("Allow notifications?")
                .font(.title2)
                .bold()
            
            Text("All Aboard needs permission to send notifications to remind you to show your ticket.")
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            HStack {
                Button("Accept", action: { action(true) })
                    .keyboardShortcut(.defaultAction)
                Button("Reject", role: .cancel, action: { action(false) })
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}

#Preview {
    NotificationPromptView() { accepted in
        print("Accepted: \(accepted)")
    }
}
