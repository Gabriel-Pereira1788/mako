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

    @Environment(\.soundManager) private var soundManager
    @State private var selectedId: String?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if devices.isEmpty {
                emptyState
            } else {
                deviceList
            }
        }
        .onAppear {
            selectedId = selectedDevice?.id
        }
        .onChange(of: selectedId) { _, newId in
            selectedDevice = devices.first { $0.id == newId }
            if newId != nil {
                soundManager?.playDeviceClick()
            }
        }
        .onChange(of: selectedDevice) { _, newDevice in
            selectedId = newDevice?.id
        }
    }

    private var header: some View {
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
        .padding(.horizontal, AppStyle.Spacing.extraLarge)
        .padding(.vertical, AppStyle.Spacing.large)
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
        List(devices, id: \.id, selection: $selectedId) { device in
            DeviceRowView(
                device: device,
                isSelected: selectedDevice?.id == device.id
            )
            .tag(device.id)
            .contextMenu {
                Button("Clear Logs", action: { onClearDevice(device) })
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
}
