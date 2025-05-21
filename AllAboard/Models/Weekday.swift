//
//  Weekday.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import Foundation

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var id: Int { rawValue }
    
    var displayName: String {
        DateFormatter().weekdaySymbols[rawValue - 1]
    }
    
    static func from(date: Date, calendar: Calendar = .current) -> Weekday {
        .init(rawValue: calendar.component(.weekday, from: date))!
    }
    
    static func from(dateComponent: Int) -> Weekday {
        .init(rawValue: dateComponent)!
    }
    
    func toDateComponent() -> Int {
        rawValue
    }
}
