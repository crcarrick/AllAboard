//
//  ScheduleService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import Foundation

class ScheduleService {
    static let shared = ScheduleService()
    
    private var timer: DispatchSourceTimer?
    private var triggered: Set<DateComponents> = []
    private var lastCleared: Int?
    
    func start() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.allaboard.scheduler", qos: .background))
        
        timer?.schedule(deadline: .now(), repeating: .seconds(60), leeway: .seconds(5))
        timer?.setEventHandler { [weak self] in
            guard let self else { return }
            Task {
                await self.checkSchedule()
            }
        }
        
        timer?.resume()
    }
    
    private func checkSchedule() async {
        let now = Date()
        let cal = Calendar.current
        let today = Calendar.current.component(.day, from: now)
        
        if lastCleared != today {
            triggered.removeAll()
            lastCleared = today
        }
        
        for time in todayTimes() {
            guard let hour = time.hour,
                  let minute = time.minute,
                  let scheduledDate = cal.date(bySettingHour: hour, minute: minute, second: 0, of: now),
                  let warningTime = cal.date(byAdding: .minute, value: -10, to: scheduledDate)
            else { continue }
            
            let rounded = cal.dateComponents([.year, .month, .day, .hour, .minute], from: warningTime)
            
            if now >= warningTime && now < scheduledDate && !triggered.contains(rounded) {
                triggered.insert(rounded)
                
                let readyPRs = await GithubService.shared.getReadyPRs()
                if !readyPRs.isEmpty {
                    NotificationService.shared.sendNotification(for: readyPRs)
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
