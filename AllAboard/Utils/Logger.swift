//
//  Logger.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/22/25.
//

import Foundation
import os

enum Log {
    static let requests = LogCategory(category: "requests")
    static let schedule = LogCategory(category: "schedule")
    static let settings = LogCategory(category: "settings")
    static let notifier = LogCategory(category: "notifier")
}

struct LogCategory {
    private let logger: Logger
    private let category: String
    
    init(category: String) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.allaboard.app", category: category)
        self.category = category
    }
    
    func info(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .info, file: file, line: line)
    }
    func debug(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .debug, file: file, line: line)
    }
    func error(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .error, file: file, line: line)
    }
    func warning(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .warning, file: file, line: line)
    }
    
    private func log(_ message: String, level: LogLevel, file: String = #file, line: Int = #line) {
        let logMessage = """
            \(level.icon) [\(Self.timestamp())] \
            [\(level.name):\(category.uppercased())] \
            [\((file as NSString).lastPathComponent):\(line)]: \
            \(message)
            """
        
        switch level {
        case .info:
            logger.info("\(logMessage, privacy: .public)")
        case .debug:
            logger.debug("\(logMessage, privacy: .public)")
        case .error:
            logger.critical("\(logMessage, privacy: .public)")
        case .notice:
            logger.notice("\(logMessage, privacy: .public)")
        case .warning:
            logger.warning("\(logMessage, privacy: .public)")
        }
    }
    
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}

private enum LogLevel: String {
    case info, debug, error, notice, warning
    
    var name: String {
        return self.rawValue.uppercased()
    }
    
    var icon: String {
        switch self {
        case .info:    return "🟦"
        case .debug:   return "🟪"
        case .error:   return "🟥"
        case .notice:  return "🟩"
        case .warning: return "🟨"
        }
    }
}
