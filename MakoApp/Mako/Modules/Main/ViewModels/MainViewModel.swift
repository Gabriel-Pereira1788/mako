//
//  MainViewModel.swift
//  Mako
//
//  Main view model managing app state, server lifecycle, and command actions
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class MainViewModel {
    // MARK: - Core Dependencies

    private(set) var server: WebSocketServer
    private(set) var deviceManager: DeviceManager
    private(set) var logStore: LogStore
    let workspaceState: WorkspaceState
    let filterManager: FilterManager

    // MARK: - State

    var selectedDevice: Device?

    // MARK: - Computed Properties

    var activeFilterContext: FilterContext? {
        guard let tab = workspaceState.activePanel?.activeTab else {
            return nil
        }
        return filterManager.context(for: tab)
    }

    var activeTabType: TabType? {
        workspaceState.activePanel?.activeTab?.type
    }

    var activeDevicePlatform: DevicePlatform {
        guard let tab = workspaceState.activePanel?.activeTab,
              let device = deviceManager.getDevice(id: tab.deviceId) else {
            return .unknown
        }
        return device.devicePlatform
    }

    // MARK: - Init

    init(modelContext: ModelContext) {
        let deviceManager = DeviceManager(modelContext: modelContext)
        self.deviceManager = deviceManager
        self.logStore = LogStore(modelContext: modelContext, deviceManager: deviceManager)
        self.server = WebSocketServer()
        self.workspaceState = WorkspaceState()
        self.filterManager = FilterManager()
    }

    // MARK: - Lifecycle

    func start() {
        setupCallbacks()
        server.start()
    }

    func stop() {
        for device in deviceManager.connectedDevices {
            logStore.clearAllForDevice(device.id)
        }
        server.stop()
    }

    // MARK: - Device Actions

    func onDeviceSelected(_ device: Device?) {
        selectedDevice = device
        if let device = device {
            workspaceState.openDeviceTabs(deviceId: device.id)
        }
    }

    func clearLogsForDevice(_ device: Device) {
        logStore.clearAllForDevice(device.id)
    }

    func clearCurrentLogs() {
        if let device = selectedDevice {
            logStore.clearAllForDevice(device.id)
        }
    }

    func clearAllLogs() {
        logStore.clearAll()
    }

    // MARK: - Command Actions

    func makeCommandActions(toggleInspector: @escaping () -> Void) -> AppCommandActions {
        AppCommandActions(
            toggleInspector: toggleInspector,
            clearLogs: { [weak self] in
                self?.clearCurrentLogs()
            },
            clearAllLogs: { [weak self] in
                self?.clearAllLogs()
            },
            openJSLogs: { [weak self] in
                guard let self, let device = selectedDevice else { return }
                workspaceState.addTab(type: .logs, deviceId: device.id)
            },
            openNetwork: { [weak self] in
                guard let self, let device = selectedDevice else { return }
                workspaceState.addTab(type: .network, deviceId: device.id)
            },
            openNativeLogs: { [weak self] in
                guard let self, let device = selectedDevice else { return }
                workspaceState.addTab(type: .nativeLogs, deviceId: device.id)
            },
            splitHorizontal: { [weak self] in
                guard let self else { return }
                workspaceState.splitDirection = .horizontal
                _ = workspaceState.addPanel()
            },
            splitVertical: { [weak self] in
                guard let self else { return }
                workspaceState.splitDirection = .vertical
                _ = workspaceState.addPanel()
            },
            closePanel: { [weak self] in
                guard let self, let panelId = workspaceState.activePanelId else { return }
                workspaceState.removePanel(id: panelId)
            },
            closeTab: { [weak self] in
                guard let self,
                      let panel = workspaceState.activePanel,
                      let tabId = panel.activeTabId else { return }
                workspaceState.closeTab(id: tabId, inPanelId: panel.id)
            },
            canSplit: workspaceState.canSplit,
            hasActiveTab: workspaceState.activePanel?.activeTabId != nil,
            hasMultiplePanels: workspaceState.panels.count > 1,
            hasSelectedDevice: selectedDevice != nil
        )
    }

    // MARK: - Private Methods

    private func setupCallbacks() {
        server.onDeviceConnected = { [weak self] deviceInfo in
            guard let self else { return }
            logStore.clearAllForDevice(deviceInfo.deviceId)

            let platform: DevicePlatform
            switch deviceInfo.platform.lowercased() {
            case "ios":
                platform = .ios
            case "android":
                platform = .android
            default:
                platform = .unknown
            }

            _ = deviceManager.getOrCreateDevice(
                id: deviceInfo.deviceId,
                name: deviceInfo.deviceName,
                platform: platform,
                appName: deviceInfo.appName,
                bundleId: deviceInfo.bundleId
            )
        }

        server.onDeviceDisconnected = { [weak self] deviceId in
            self?.deviceManager.markDisconnected(id: deviceId)
        }

        server.onNetworkReceived = { [weak self] event in
            self?.logStore.addNetworkEvent(event)
        }

        server.onLogReceived = { [weak self] event in
            self?.logStore.addLog(event)
        }
    }
}
