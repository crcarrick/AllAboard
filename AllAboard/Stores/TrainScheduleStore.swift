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
    
    private static let defaultSchedule: TrainSchedule = [
        .monday: [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 13, minute: 0),
            TrainTime(hour: 16, minute: 0),
        ],
        .tuesday: [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 16, minute: 0),
        ],
        .wednesday: [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 13, minute: 0),
            TrainTime(hour: 16, minute: 0),
        ],
        .thursday: [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 16, minute: 0),
        ],
        .friday: [
            TrainTime(hour: 10, minute: 0),
            TrainTime(hour: 13, minute: 0),
        ],
    ]
    
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
    
    func reset() {
        self.schedule = TrainScheduleStore.defaultSchedule
        save()
    }
    
    func isDefaultSchedule() -> Bool {
        return schedule == TrainScheduleStore.defaultSchedule
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(schedule) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(TrainSchedule.self, from: data) {
            self.schedule = decoded
        } else {
            reset()
        }
    }
}
