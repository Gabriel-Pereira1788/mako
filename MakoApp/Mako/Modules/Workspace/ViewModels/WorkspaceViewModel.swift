//
//  WorkspaceViewModel.swift
//  Mako
//
//  Manages workspace state including panels, tabs, and splits
//

import Foundation
import Observation

@MainActor
@Observable
final class WorkspaceViewModel {
    // MARK: - State

    var panels: [Panel] = []
    var activePanelId: UUID?
    var splitDirection: SplitDirection = .horizontal

    static let maxPanels = 3

    // MARK: - Init

    init() {
        let panel = Panel()
        panels = [panel]
        activePanelId = panel.id
    }

    // MARK: - Computed Properties

    var activePanel: Panel? {
        guard let id = activePanelId else { return nil }
        return panels.first { $0.id == id }
    }

    var canSplit: Bool {
        panels.count < Self.maxPanels
    }

    // MARK: - Panel Actions

    func addPanel() -> Panel? {
        guard canSplit else { return nil }
        let panel = Panel()
        panels.append(panel)
        activePanelId = panel.id
        return panel
    }

    func removePanel(id: UUID) {
        panels.removeAll { $0.id == id }
        if activePanelId == id {
            activePanelId = panels.first?.id
        }
    }

    func setActivePanel(_ id: UUID) {
        activePanelId = id
    }

    // MARK: - Tab Actions

    func addTab(type: TabType, deviceId: String, toPanelId: UUID? = nil) {
        let panelId = toPanelId ?? activePanelId ?? panels.first?.id
        guard let panelId = panelId,
              let panelIndex = panels.firstIndex(where: { $0.id == panelId }) else {
            return
        }

        let tab = Tab(type: type, deviceId: deviceId)
        panels[panelIndex].tabs.append(tab)
        panels[panelIndex].activeTabId = tab.id
        activePanelId = panelId
    }

    func closeTab(id: UUID, inPanelId: UUID) {
        guard let panelIndex = panels.firstIndex(where: { $0.id == inPanelId }) else {
            return
        }

        panels[panelIndex].tabs.removeAll { $0.id == id }

        if panels[panelIndex].activeTabId == id {
            panels[panelIndex].activeTabId = panels[panelIndex].tabs.first?.id
        }
    }

    func setActiveTab(id: UUID, inPanelId: UUID) {
        guard let panelIndex = panels.firstIndex(where: { $0.id == inPanelId }) else {
            return
        }
        panels[panelIndex].activeTabId = id
        activePanelId = inPanelId
    }

    // MARK: - Device Actions

    func openDeviceTabs(deviceId: String) {
        if let panelIndex = panels.firstIndex(where: { $0.id == activePanelId }) {
            panels[panelIndex].tabs.removeAll()
            let logsTab = Tab(type: .logs, deviceId: deviceId)
            let networkTab = Tab(type: .network, deviceId: deviceId)
            let nativeLogsTab = Tab(type: .nativeLogs, deviceId: deviceId)
            panels[panelIndex].tabs = [logsTab, networkTab, nativeLogsTab]
            panels[panelIndex].activeTabId = logsTab.id
        }
    }

    func closeAllTabsForDevice(_ deviceId: String) {
        for i in panels.indices {
            panels[i].tabs.removeAll { $0.deviceId == deviceId }
            if let activeTabId = panels[i].activeTabId,
               !panels[i].tabs.contains(where: { $0.id == activeTabId }) {
                panels[i].activeTabId = panels[i].tabs.first?.id
            }
        }
    }
}

// MARK: - Type Alias for backwards compatibility
typealias WorkspaceState = WorkspaceViewModel
