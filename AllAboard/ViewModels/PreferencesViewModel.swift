//
//  PreferencesViewModel.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import ServiceManagement
import SwiftUI

protocol PreferencesViewModelProtocol: ObservableObject {
    var weekday: Weekday { get set }
    var timeVal: TrainTime { get set }
    var ghToken: String { get set }
    var ghSaved: Bool { get set }
    var showErr: Bool { get set }
    
    var times: [TrainTime] { get }
    var sortedTimes: [TrainTime] { get }
    
    func appendTime()
    func isDefaultSchedule() -> Bool
    func removeTime(time: TrainTime)
    func resetSchedule()
    func saveToken()
    func toggleLaunchAtLogin(_ enabled: Bool)
}

class PreferencesViewModel: ObservableObject, PreferencesViewModelProtocol {
    @ObservedObject var store: TrainScheduleStore = TrainScheduleStore()
    
    @Published var weekday: Weekday = .monday
    @Published var timeVal: TrainTime = TrainTime(hour: 0, minute: 0)
    @Published var ghToken: String = ""
    @Published var ghSaved: Bool = false
    @Published var showErr: Bool = false
    
    init() {
        self.ghToken = GithubTokenStore.loadToken() ?? ""
    }
    
    var times: [TrainTime] {
        return store.schedule[weekday, default: []]
    }
    
    var sortedTimes: [TrainTime] {
        return times.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }
    
    func appendTime() {
        if times.contains(where: { $0.hour == timeVal.hour && $0.minute == timeVal.minute }) {
            showErr = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showErr = false
            }
            
            return
        }
        
        withAnimation(.easeInOut(duration: 0.1)) {
            store.appendTime(timeVal, for: weekday)
            timeVal = TrainTime(hour: timeVal.hour, minute: timeVal.minute)
            showErr = false
        }
    }
    
    func isDefaultSchedule() -> Bool {
        store.isDefaultSchedule()
    }
    
    func removeTime(time: TrainTime) {
        withAnimation(.easeInOut(duration: 0.1)) {
            store.removeTime(time, for: weekday)
        }
    }
    
    func resetSchedule() {
        store.reset()
    }
    
    func saveToken() {
        GithubTokenStore.saveToken(ghToken)
        
        ghSaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.ghSaved = false
        }
    }
    
    func toggleLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            Log.settings.warning("Failed to update login item status: \(error)")
        }
    }
}

final class MockPreferencesViewModel: PreferencesViewModelProtocol {
    var weekday: Weekday = .monday
    var timeVal: TrainTime = TrainTime(hour: 0, minute: 0)
    var ghToken: String = ""
    var ghSaved: Bool = false
    var showErr: Bool = false
    
    var times: [TrainTime] {
        return [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 11, minute: 0),
        ]
    }
    
    var sortedTimes: [TrainTime] {
        return [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 11, minute: 0),
        ]
    }
    
    func appendTime() {
        print("Mock appendTime")
    }
    
    func isDefaultSchedule() -> Bool {
        return true
    }
    
    func removeTime(time: TrainTime) {
        print("Mock removeTime: \(time)")
    }
    
    func resetSchedule() {
        print("Mock resetSchedule")
    }
    
    func saveToken() {
        print("Mock saveToken")
    }
    
    func toggleLaunchAtLogin(_ enabled: Bool) {
        print("Mock toggleLaunchAtLogin: \(enabled)")
    }
}
