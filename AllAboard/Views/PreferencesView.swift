//
//  PreferencesView.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var vm: PreferencesViewModel
    @StateObject private var store: TrainScheduleStore
    
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
                
                SecureField("Personal Access Token", text: $vm.githubToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Store a token with `repo` scope.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Deploy Train Schedule")
                    .font(.headline)

                Picker("Day:", selection: $vm.weekday) {
                    ForEach(Weekday.allCases) { day in
                        Text(day.displayName).tag(day)
                    }
                }
                .labelsHidden()
                .pickerStyle(PopUpButtonPickerStyle())
                .frame(width: 200)

                if vm.times.isEmpty {
                    Text("No times added yet.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding(.vertical, 4)
                } else {
                    VStack(spacing: 6) {
                        ForEach(vm.sortedTimes) { time in
                            HStack {
                                Text(time.formatted)
                                    .font(.system(.body, design: .monospaced))
                                
                                Spacer()
                                
                                Button(action: { vm.removeTime(time: time) }) {
                                    Image(systemName: "xmark.circle.fill")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.horizontal, 6)
                        }
                    }
                }

                HStack {
                    TextField("HH:mm", text: $vm.timeStr)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: { vm.appendTime(time: vm.timeStr) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Add deploy time")
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 420, height: 420)
    }
}
