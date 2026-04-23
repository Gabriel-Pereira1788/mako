//
//  WorkspaceView.swift
//  Mako
//
//  Main workspace area with split panels
//

import SwiftUI

struct WorkspaceView: View {
    @Bindable var workspaceState: WorkspaceState
    let deviceManager: DeviceManager
    let filterManager: FilterManager

    var body: some View {
        Group {
            if workspaceState.panels.isEmpty {
                emptyWorkspace
            } else if workspaceState.panels.count == 1 {
                singlePanel
            } else {
                splitPanels
            }
        }
    }

    private var emptyWorkspace: some View {
        VStack(spacing: 16) {
            Image(systemName: "macwindow")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            Text("Welcome to Mako")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Select a device from the sidebar to start debugging")
                .font(.body)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var singlePanel: some View {
        if let panel = workspaceState.panels.first {
            PanelView(
                panel: panel,
                deviceManager: deviceManager,
                filterManager: filterManager,
                onSelectTab: { tabId in
                    workspaceState.setActiveTab(id: tabId, inPanelId: panel.id)
                },
                onCloseTab: { tabId in
                    workspaceState.closeTab(id: tabId, inPanelId: panel.id)
                }
            )
        } else {
            emptyWorkspace
        }
    }

    @ViewBuilder
    private var splitPanels: some View {
        if workspaceState.splitDirection == .horizontal {
            VSplitView {
                ForEach(workspaceState.panels) { panel in
                    panelContainer(for: panel)
                }
            }
        } else {
            HSplitView {
                ForEach(workspaceState.panels) { panel in
                    panelContainer(for: panel)
                }
            }
        }
    }

    private func panelContainer(for panel: Panel) -> some View {
        PanelView(
            panel: panel,
            deviceManager: deviceManager,
            filterManager: filterManager,
            onSelectTab: { tabId in
                workspaceState.setActiveTab(id: tabId, inPanelId: panel.id)
            },
            onCloseTab: { tabId in
                workspaceState.closeTab(id: tabId, inPanelId: panel.id)
            }
        )
        .overlay(alignment: .topTrailing) {
            if workspaceState.panels.count > 1 {
                Button("Close Panel", systemImage: "xmark.circle.fill") {
                    workspaceState.removePanel(id: panel.id)
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
                .padding(8)
            }
        }
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            workspaceState.setActivePanel(panel.id)
        }
        .border(
            workspaceState.activePanelId == panel.id ? AppStyle.Panel.activeBorderColor : Color.clear,
            width: AppStyle.Panel.activeBorderWidth
        )
    }
}
