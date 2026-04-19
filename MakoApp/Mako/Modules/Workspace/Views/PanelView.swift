//
//  PanelView.swift
//  Mako
//
//  A single panel containing tabs and content
//

import SwiftUI
import SwiftData

struct PanelView: View {
    let panel: Panel
    let deviceManager: DeviceManager
    let onSelectTab: (UUID) -> Void
    let onCloseTab: (UUID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(
                tabs: panel.tabs,
                activeTabId: panel.activeTabId,
                onSelectTab: onSelectTab,
                onCloseTab: onCloseTab
            )

            Divider()

            if let activeTab = panel.activeTab {
                tabContent(for: activeTab)
            } else {
                emptyState
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        let device = deviceManager.getDevice(id: tab.deviceId)

        switch tab.type {
        case .logs:
            LogsContentView(device: device)
        case .network:
            NetworkContentView(device: device)
        case .nativeLogs:
            NativeLogsContentView(device: device)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.dashed")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No tabs open")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Select a device to view logs and network")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

