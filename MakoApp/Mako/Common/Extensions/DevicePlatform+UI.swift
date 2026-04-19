//
//  DevicePlatform+UI.swift
//  Mako
//

import SwiftUI

extension DevicePlatform {
    var color: Color {
        switch self {
        case .ios: return .blue
        case .android: return .green
        case .unknown: return .gray
        }
    }
}
