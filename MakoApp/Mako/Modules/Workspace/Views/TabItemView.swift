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

                Button("Close Tab", systemImage: "xmark", action: onClose)
                    .labelStyle(.iconOnly)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                    .opacity(isHovering || isActive ? 1 : 0)
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
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
