//
//  TrainScheduleStore.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import Foundation

typealias TrainSchedule = [Weekday: [TrainTime]]

class TrainScheduleStore: ObservableObject {
    @Published var schedule: TrainSchedule = [:]
    
    private let storageKey = "trainSchedule"
    
    init() {
        load()
    }
    
    func appendTime(_ time: TrainTime, for weekday: Weekday) {
        schedule[weekday, default: []].append(time)
        save()
    }
    
    func removeTime(_ time: TrainTime, for weekday: Weekday) {
        schedule[weekday]?.removeAll { $0 == time }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(schedule) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(TrainSchedule.self, from: data) else { return }
        
        schedule = decoded
    }
}
