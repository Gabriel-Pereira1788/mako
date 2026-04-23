//
//  SidebarView.swift
//  Mako
//
//  Sidebar containing device list and connection status
//

import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: MainViewModel

    var body: some View {
        VStack(spacing: 0) {
            DeviceListView(
                devices: viewModel.deviceManager.devices,
                selectedDevice: $viewModel.selectedDevice,
                onClearDevice: { device in
                    viewModel.clearLogsForDevice(device)
                }
            )

            Divider()

            ConnectionStatusView(server: viewModel.server)
        }
        .background(AppStyle.Background.primary)
        .onChange(of: viewModel.selectedDevice) { _, newDevice in
            if let device = newDevice {
                viewModel.workspaceState.openDeviceTabs(deviceId: device.id)
            }
        }
    }
}
