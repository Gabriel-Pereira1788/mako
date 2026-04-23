//
//  DeviceRowView.swift
//  Mako
//
//  Displays a single device in the sidebar
//

import SwiftUI

struct DeviceRowView: View {
    let device: Device
    let isSelected: Bool

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            platformIcon
            deviceInfo
            Spacer()
            connectionIndicator
        }
        .padding(.vertical, AppStyle.Spacing.medium)
        .padding(.horizontal, AppStyle.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppStyle.Border.radius)
                .fill(rowBackgroundColor)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var rowBackgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.2)
        } else if isHovering {
            return Color.secondary.opacity(0.1)
        }
        return Color.clear
    }

    // MARK: - Subviews

    private var platformIcon: some View {
        Group {
            if device.platform == "android" {
                Image(device.devicePlatform.iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(device.devicePlatform.color)
                    .frame(width: 50, height: 50)
            } else {
                Image(systemName: device.devicePlatform.iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(device.devicePlatform.color)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 40, height: 40)
    }

    private var deviceInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(device.name)
                .font(.headline)
                .lineLimit(1)

            if !device.appName.isEmpty {
                Text(device.appName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var connectionIndicator: some View {
        Circle()
            .fill(device.isConnected ? .green : .gray)
            .frame(width: 8, height: 8)
    }
}
