//
//  ScheduleService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import Foundation

class ScheduleService {
    static let shared = ScheduleService()
    
    private var timer: Timer?
    private var triggered: Set<DateComponents> = []
    private var lastCleared: Int?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.checkSchedule()
        }
    }
    
    private func checkSchedule() {
        let now = Date()
        let today = Calendar.current.component(.day, from: now)
        
        if lastCleared != today {
            triggered.removeAll()
            lastCleared = today
        }
        
        for time in todayTimes() {
            guard let scheduledDate = Calendar.current.date(from: time),
                  let warningTime = Calendar.current.date(byAdding: .minute, value: -10, to: scheduledDate) else { continue }
            
            let delta = now.timeIntervalSince(warningTime)
            
            if delta >= 0 && delta < 120 {
                let rounded = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: warningTime)
                
                if !triggered.contains(rounded) {
                    triggered.insert(rounded)
                    GithubService.shared.checkForReadyPRs { prs in
                        if !prs.isEmpty {
                            NotificationService.shared.sendNotification(for: prs)
                        }
                    }
                }
            }
        }
    }
    
    private func todayTimes() -> [DateComponents] {
        let store = TrainScheduleStore()
        let weekday = Weekday.from(date: Date())
        
        return store.schedule[weekday, default: []].map {
            DateComponents(hour: $0.hour, minute: $0.minute)
        }
    }
}
