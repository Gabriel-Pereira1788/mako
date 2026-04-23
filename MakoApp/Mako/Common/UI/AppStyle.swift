//
//  AppStyle.swift
//  Mako
//
//  Centralized style constants for consistent UI
//

import SwiftUI

enum AppStyle {

    // MARK: - Border

    enum Border {
        static let color = Color(nsColor: .separatorColor)
        static let width: CGFloat = 1
        static let radius: CGFloat = 8
    }

    // MARK: - Background

    enum Background {
        static let primary = Color(nsColor: .windowBackgroundColor)
        static let secondary = Color(nsColor: .controlBackgroundColor)
    }

    // MARK: - Spacing

    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
    }

    // MARK: - Panel

    enum Panel {
        static let activeBorderColor = Color.accentColor.opacity(0.5)
        static let activeBorderWidth: CGFloat = 2
    }
}
