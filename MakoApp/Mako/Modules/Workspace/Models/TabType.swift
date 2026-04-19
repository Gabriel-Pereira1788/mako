//
//  TabType.swift
//  Mako
//

import Foundation

enum TabType: String, Codable, CaseIterable {
    case logs
    case network
    case nativeLogs

    var displayName: String {
        switch self {
        case .logs: return "JS Logs"
        case .network: return "Network"
        case .nativeLogs: return "Native Logs"
        }
    }

    var iconName: String {
        switch self {
        case .logs: return "text.alignleft"
        case .network: return "network"
        case .nativeLogs: return "apple.terminal"
        }
    }
}
