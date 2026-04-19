//
//  LogSource.swift
//  Mako
//

import Foundation

enum LogSource: String, Codable, CaseIterable {
    case js
    case ios
    case android

    var displayName: String {
        switch self {
        case .js: return "JavaScript"
        case .ios: return "iOS"
        case .android: return "Android"
        }
    }
}
