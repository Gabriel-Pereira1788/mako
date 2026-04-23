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
    let filterManager: FilterManager
    let onSelectTab: (UUID) -> Void
    let onCloseTab: (UUID) -> Void
    var onCloseOtherTabs: ((UUID) -> Void)? = nil
    var onCloseTabsToRight: ((UUID) -> Void)? = nil
    var onMoveToNewPanel: ((UUID) -> Void)? = nil
    var canMoveToNewPanel: Bool = false
    var onSplitHorizontal: (() -> Void)? = nil
    var onSplitVertical: (() -> Void)? = nil
    var onClosePanel: (() -> Void)? = nil
    var canSplit: Bool = false
    var canClosePanel: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(
                tabs: panel.tabs,
                activeTabId: panel.activeTabId,
                onSelectTab: onSelectTab,
                onCloseTab: onCloseTab,
                onCloseOtherTabs: onCloseOtherTabs,
                onCloseTabsToRight: onCloseTabsToRight,
                onMoveToNewPanel: onMoveToNewPanel,
                canMoveToNewPanel: canMoveToNewPanel
            )

            Divider()

            if let activeTab = panel.activeTab {
                tabContent(for: activeTab)
            } else {
                emptyState
            }
        }
        .contextMenu {
            if canSplit {
                Button("Split Horizontal") {
                    onSplitHorizontal?()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])

                Button("Split Vertical") {
                    onSplitVertical?()
                }
                .keyboardShortcut("d", modifiers: [.command, .option])
            }

            if canClosePanel {
                if canSplit {
                    Divider()
                }

                Button("Close Panel") {
                    onClosePanel?()
                }
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        let device = deviceManager.getDevice(id: tab.deviceId)
        let filterContext = filterManager.context(for: tab)

        switch tab.type {
        case .logs:
            LogsContentView(device: device, filterContext: filterContext)
        case .network:
            NetworkContentView(device: device, filterContext: filterContext)
        case .nativeLogs:
            NativeLogsContentView(device: device, filterContext: filterContext)
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

