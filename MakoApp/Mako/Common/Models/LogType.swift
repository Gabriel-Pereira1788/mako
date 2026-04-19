//
//  LogType.swift
//  Mako
//
//  Represents the type of log event (JS vs Native)
//

import Foundation

enum LogType: String, Codable, CaseIterable {
    case log      // JavaScript logs
    case native   // Native platform logs (iOS/Android)

    var displayName: String {
        switch self {
        case .log: return "JavaScript"
        case .native: return "Native"
        }
    }
}
