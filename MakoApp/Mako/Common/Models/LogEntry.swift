//
//  LogEntry.swift
//  Mako
//

import Foundation
import SwiftData

@Model
final class LogEntry {
    var id: UUID
    var timestamp: Date
    var level: String
    var source: String
    var logType: String = "log"  // Default value for migration
    var message: String
    var metadata: String?

    @Relationship var device: Device?

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        level: LogLevel,
        source: LogSource,
        logType: LogType = .log,
        message: String,
        metadata: String? = nil,
        device: Device? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level.rawValue
        self.source = source.rawValue
        self.logType = logType.rawValue
        self.message = message
        self.metadata = metadata
        self.device = device
    }

    var logLevel: LogLevel {
        LogLevel(rawValue: level) ?? .info
    }

    var logSource: LogSource {
        LogSource(rawValue: source) ?? .js
    }

    var entryLogType: LogType {
        LogType(rawValue: logType) ?? .log
    }
}
