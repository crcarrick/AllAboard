//
//  PreferencesViewModel.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import SwiftUI

class PreferencesViewModel: ObservableObject {
    @ObservedObject var store: TrainScheduleStore
    
    @Published var weekday: Weekday = .monday
    @Published var timeVal: TrainTime = TrainTime(hour: 0, minute: 0)
    @Published var ghToken: String = ""
    @Published var ghSaved: Bool = false
    @Published var showErr: Bool = false
    
    init(store: TrainScheduleStore) {
        self.store = store
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
    
    func removeTime(time: TrainTime) {
        withAnimation(.easeInOut(duration: 0.1)) {
            store.removeTime(time, for: weekday)
        }
    }
    
    func saveToken() {
        GithubTokenStore.saveToken(ghToken)
        
        ghSaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.ghSaved = false
        }
    }
}
