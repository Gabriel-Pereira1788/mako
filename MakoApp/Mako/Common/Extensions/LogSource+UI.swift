//
//  LogSource+UI.swift
//  Mako
//

import SwiftUI

extension LogSource {
    var color: Color {
        switch self {
        case .js: return .yellow
        case .ios: return .blue
        case .android: return .green
        }
    }
}
