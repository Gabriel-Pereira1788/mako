//
//  DeviceListView.swift
//  Mako
//
//  Left sidebar showing list of connected devices
//

import SwiftUI

struct DeviceListView: View {
    let devices: [Device]
    @Binding var selectedDevice: Device?
    let onClearDevice: (Device) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Devices")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(devices.count)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            if devices.isEmpty {
                emptyState
            } else {
                deviceList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "iphone.slash")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("No devices connected")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Connect a React Native app\nto see it here")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var deviceList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(devices, id: \.id) { device in
                    Button {
                        selectedDevice = device
                    } label: {
                        DeviceRowView(
                            device: device,
                            isSelected: selectedDevice?.id == device.id
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Clear Logs") {
                            onClearDevice(device)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
    }
}
