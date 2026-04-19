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

    var body: some View {
        HStack(spacing: 12) {
            platformIcon
            deviceInfo
            Spacer()
            connectionIndicator
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .contentShape(Rectangle())
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
