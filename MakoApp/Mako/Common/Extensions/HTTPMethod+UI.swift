//
//  HTTPMethod+UI.swift
//  Mako
//

import SwiftUI

enum HTTPMethod {
    static func color(for method: String) -> Color {
        switch method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        case "PATCH": return .purple
        default: return .secondary
        }
    }
}
