//
//  TabItemView.swift
//  Mako
//
//  Individual tab item in the tab bar
//

import SwiftUI

struct TabItemView: View {
    let tab: Tab
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    var onCloseOthers: (() -> Void)? = nil
    var onCloseToRight: (() -> Void)? = nil
    var onMoveToNewPanel: (() -> Void)? = nil
    var canMoveToNewPanel: Bool = false

    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Image(systemName: tab.type.iconName)
                    .font(.caption)
                    .foregroundStyle(isActive ? .primary : .secondary)

                Text(tab.type.displayName)
                    .font(.caption)
                    .foregroundStyle(isActive ? .primary : .secondary)
                    .lineLimit(1)

            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(isActive ? Color(nsColor: .windowBackgroundColor) : Color.clear)
            )
            .overlay(alignment: .bottom) {
                if isActive {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(.borderless)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button("Close Tab") {
                onClose()
            }
            .keyboardShortcut("w", modifiers: .command)

            if let onCloseOthers {
                Button("Close Other Tabs") {
                    onCloseOthers()
                }
            }

            if let onCloseToRight {
                Button("Close Tabs to the Right") {
                    onCloseToRight()
                }
            }

            if canMoveToNewPanel, let onMoveToNewPanel {
                Divider()

                Button("Move to New Panel") {
                    onMoveToNewPanel()
                }
            }
        }
        .accessibilityLabel("\(tab.type.displayName) tab")
        .accessibilityHint(isActive ? "Currently active" : "Double-tap to switch to this tab")
        .accessibilityAddTraits(.isButton)
    }
}
