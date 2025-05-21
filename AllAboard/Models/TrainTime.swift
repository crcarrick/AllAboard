//
//  TrainTime.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import Foundation

struct TrainTime: Codable, Identifiable, Equatable {
    var id = UUID()
    var hour: Int
    var minute: Int
    
    var formatted: String {
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        let amOrPM = hour < 12 ? "AM" : "PM"
        return String(format: "%02d:%02d %@", hour12, minute, amOrPM)
    }
    
    static func == (lhs: TrainTime, rhs: TrainTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
}
