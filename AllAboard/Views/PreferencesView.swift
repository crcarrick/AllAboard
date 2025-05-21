//
//  PreferencesView.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    @StateObject private var vm: PreferencesViewModel
    @StateObject private var store: TrainScheduleStore
    
    @State private var showResetConfirmation: Bool = false
    
    init() {
        let store = TrainScheduleStore()
        
        _vm = .init(wrappedValue: PreferencesViewModel(store: store))
        _store = .init(wrappedValue: store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("GitHub")
                    .font(.headline)
                
                SecureField("Personal Access Token", text: $vm.ghToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(alignment: .trailing) {
                        if vm.ghSaved {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .padding(.trailing, 8)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: vm.ghSaved)

                HStack {
                    Text("Store a token with `repo` scope.  Must be SSO enabled.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Save") {
                        vm.saveToken()
                    }
                    .disabled(vm.ghToken.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Schedule")
                        .font(.headline)
                    
                    if !store.isDefaultSchedule() {
                        Spacer()
                        
                        Button("Reset") {
                            showResetConfirmation = true
                        }
                        .font(.callout)
                        .buttonStyle(.link)
                        .foregroundColor(.red)
                        .help("Restore the original train schedule")
                        .confirmationDialog(
                            "Reset schedule?",
                            isPresented: $showResetConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Reset", role: .destructive) {
                                vm.resetSchedule()
                            }
                        } message: {
                            Text("This will erase your current deploy train times and restore the default schedule.")
                        }
                    }
                }
                
                Text("Configure the deploy train schedule.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(alignment: .center) {
                    Picker("Day:", selection: $vm.weekday) {
                        ForEach(Weekday.allCases.filter({ ![.sunday, .saturday].contains($0) })) { day in
                            Text(day.displayName).tag(day)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        if vm.times.isEmpty {
                            Label("No times scheduled", systemImage: "clock.badge.exclamationmark")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(vm.sortedTimes) { time in
                                HStack {
                                    Text(time.formatted)
                                        .font(.system(.body, design: .monospaced))
                                    
                                    Spacer()
                                    
                                    Button(action: { vm.removeTime(time: time) }) {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.horizontal, 6)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }
                }
                .padding()
                .background()
                .frame(maxHeight: 150)
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        TrainTimePickerView(time: $vm.timeVal) {
                            vm.appendTime()
                        }
                        
                        Label("That time is already scheduled.", systemImage: "exclamationmark.triangle.fill")
                            .font(.callout)
                            .foregroundColor(.red)
                            .opacity(vm.showErr ? 1 : 0)
                            .animation(.easeInOut, value: vm.showErr)
                    }
                }
            }
            
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, val in
                    vm.toggleLaunchAtLogin(val)
                }
        }
        .padding(24)
        .frame(width: 420, height: 440)
    }
}

#Preview {
  PreferencesView()
}
