//
//  MenuContentView.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/21/25.
//

import SwiftUI

struct MenuContentView<VM: MenuContentViewModelProtocol>: View {
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

extension MenuContentView where VM == MenuContentViewModel {
    init() {
        self.init(vm: MenuContentViewModel())
    }
}

#Preview {
    // TODO: Doesn't look at all like the real menu bar
    MenuContentView(vm: MockMenuContentViewModel())
        .padding()
}
