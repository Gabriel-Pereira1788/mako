//
//  DeviceManager.swift
//  Mako
//
//  Manages connected devices and their lifecycle
//

import Foundation
import Observation
import SwiftData
import OSLog

@MainActor
@Observable
final class DeviceManager {
    private let logger = Logger(subsystem: "com.rntrace", category: "DeviceManager")
    private let modelContext: ModelContext

    var devices: [Device] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadDevices()
    }

    // MARK: - Device Operations

    func getOrCreateDevice(id: String, name: String? = nil, platform: DevicePlatform? = nil, appName: String? = nil, bundleId: String? = nil) -> Device {
        if let existing = devices.first(where: { $0.id == id }) {

            if let name = name, !name.isEmpty {
                existing.name = name
            }
            if let platform = platform, platform != .unknown {
                existing.platform = platform.rawValue
            }
            if let appName = appName, !appName.isEmpty {
                existing.appName = appName
            }
            if let bundleId = bundleId, !bundleId.isEmpty {
                existing.bundleId = bundleId
            }
            existing.lastSeen = .now
            existing.isConnected = true
            saveContext()
            return existing
        }

        let device = Device(
            id: id,
            name: name ?? "React Native",
            platform: platform ?? .unknown,
            appName: appName ?? "",
            bundleId: bundleId,
            lastSeen: .now,
            isConnected: true
        )

        modelContext.insert(device)
        devices.append(device)
        saveContext()
        logger.info("Created new device: \(device.displayName) (\(id))")
        return device
    }

    func getDevice(id: String) -> Device? {
        devices.first { $0.id == id }
    }

    func updateDeviceInfo(id: String, name: String?, platform: DevicePlatform?, appName: String?, bundleId: String? = nil) {
        guard let device = getDevice(id: id) else {
            logger.warning("Device not found for update: \(id)")
            return
        }

        if let name = name, !name.isEmpty {
            device.name = name
        }
        if let platform = platform, platform != .unknown {
            device.platform = platform.rawValue
        }
        if let appName = appName, !appName.isEmpty {
            device.appName = appName
        }
        if let bundleId = bundleId, !bundleId.isEmpty {
            device.bundleId = bundleId
        }
        device.lastSeen = .now
        saveContext()
        logger.info("Updated device info: \(device.displayName)")
    }

    func updateLastSeen(id: String) {
        guard let device = getDevice(id: id) else { return }
        device.lastSeen = .now
        saveContext()
    }

    func markConnected(id: String) {
        guard let device = getDevice(id: id) else { return }
        device.isConnected = true
        device.lastSeen = .now
        saveContext()
        logger.info("Device connected: \(device.displayName)")
    }

    func markDisconnected(id: String) {
        guard let device = getDevice(id: id) else { return }
        device.isConnected = false
        saveContext()
        logger.info("Device disconnected: \(device.displayName)")
    }

    func removeDevice(id: String) {
        guard let device = getDevice(id: id) else { return }
        modelContext.delete(device)
        devices.removeAll { $0.id == id }
        saveContext()
        logger.info("Removed device: \(id)")
    }

    func clearAllDevices() {
        for device in devices {
            modelContext.delete(device)
        }
        devices.removeAll()
        saveContext()
        logger.info("Cleared all devices")
    }

    // MARK: - Queries

    var connectedDevices: [Device] {
        devices.filter { $0.isConnected }
    }

    // MARK: - Private

    private func loadDevices() {
        let descriptor = FetchDescriptor<Device>(
            sortBy: [SortDescriptor(\.lastSeen, order: .reverse)]
        )

        do {
            devices = try modelContext.fetch(descriptor)
            for device in devices {
                device.isConnected = false
            }
            saveContext()
            logger.info("Loaded \(self.devices.count) devices from storage")
        } catch {
            logger.error("Failed to load devices: \(error.localizedDescription)")
            devices = []
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
}
