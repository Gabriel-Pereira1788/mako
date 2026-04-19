//
//  DevicePlatform.swift
//  Mako
//

import Foundation

enum DevicePlatform: String, Codable, CaseIterable {
    case ios
    case android
    case unknown

    var displayName: String {
        switch self {
        case .ios: return "iOS"
        case .android: return "Android"
        case .unknown: return "Unknown"
        }
    }

    var iconName: String {
        switch self {
        case .ios: return "apple.logo"
        case .android: return "AndroidLogo"
        case .unknown: return "questionmark.circle"
        }
    }
}
