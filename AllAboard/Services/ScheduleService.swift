//
//  ScheduleService.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import AppKit
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
                Log.schedule.debug("Checking schedule on timer")
                await self.checkSchedule()
            }
        }
        
        timer?.resume()
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc private func handleWake() {
        Task {
            Log.schedule.debug("Checking schedule after wakeup")
            await checkSchedule()
        }
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
                Log.schedule.debug("Within 10 minutes of scheduled time for \(scheduledDate)")
                
                triggered.insert(rounded)
                
                let readyPRs = await GithubService.shared.getReadyPRs()
                if !readyPRs.isEmpty {
                    await NotificationService.shared.sendNotification(for: readyPRs)
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
