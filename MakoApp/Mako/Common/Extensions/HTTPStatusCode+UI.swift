//
//  HTTPStatusCode+UI.swift
//  Mako
//

import SwiftUI

enum HTTPStatusCode {
    static func color(for code: Int?) -> Color {
        guard let code else { return .gray }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }
}
