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
        MenuContentViewBodyView(vm: MenuContentViewModel(openSettings: openSettings))
    }
}

private struct MenuContentViewBodyView<VM: MenuContentViewModelProtocol>: View {
    @ObservedObject var vm: VM
    
    var body: some View {
        VStack {
            Button("Check PRs Now", action: vm.checkPRsNow)
            .keyboardShortcut("r")
            
            Divider()
            
            Button("Settings", action: vm.viewSettings)
            .keyboardShortcut(",")
            
            Button("Quit", action: vm.quit)
            .keyboardShortcut("q")
        }
    }
}

#Preview {
    // TODO: Doesn't look at all like the real menu bar
    MenuContentViewBodyView(vm: MockMenuContentViewModel())
        .padding()
}
