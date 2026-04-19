//
//  DeviceListViewModel.swift
//  Mako
//

import Foundation
import Observation

@MainActor
@Observable
final class DeviceListViewModel {
    // MARK: - Dependencies

    private let deviceManager: DeviceManager
    private let logStore: LogStore

    // MARK: - State

    var selectedDevice: Device?

    // MARK: - Computed Properties

    var devices: [Device] { deviceManager.devices }
    var deviceCount: Int { devices.count }
    var hasDevices: Bool { !devices.isEmpty }

    // MARK: - Init

    init(deviceManager: DeviceManager, logStore: LogStore) {
        self.deviceManager = deviceManager
        self.logStore = logStore
    }

    // MARK: - Actions

    func selectDevice(_ device: Device) {
        selectedDevice = device
    }

    func clearDeviceData(_ device: Device) {
        logStore.clearAllForDevice(device.id)
    }

    func isSelected(_ device: Device) -> Bool {
        selectedDevice?.id == device.id
    }
}
