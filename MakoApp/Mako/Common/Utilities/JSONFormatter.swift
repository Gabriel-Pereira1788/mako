//
//  JSONFormatter.swift
//  Mako
//

import Foundation

enum JSONFormatter {
    static func format(_ string: String) -> String {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let formatted = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let result = String(data: formatted, encoding: .utf8) else {
            return string
        }
        return result
    }
}
