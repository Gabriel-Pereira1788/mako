//
//  LogStore.swift
//  Mako
//

import Foundation
import Observation
import SwiftData
import OSLog

@MainActor
@Observable
final class LogStore {
    private let modelContext: ModelContext
    private let deviceManager: DeviceManager
    private let logger = Logger(subsystem: "com.rntrace", category: "LogStore")

    private var pendingNetworkRequests: [String: NetworkEntry] = [:]

    init(modelContext: ModelContext, deviceManager: DeviceManager) {
        self.modelContext = modelContext
        self.deviceManager = deviceManager
    }

    func addLog(_ event: IncomingLogEvent, deviceId: String? = nil) {
        let level = LogLevel(rawValue: event.level) ?? .info
        let source = LogSource(rawValue: event.source) ?? .js
        let logType = LogType(rawValue: event.type) ?? .log

        var metadataString: String?
        if let metadata = event.metadata {
            if let data = try? JSONEncoder().encode(metadata) {
                metadataString = String(data: data, encoding: .utf8)
            }
        }

        let timestamp: Date
        if let ts = event.timestamp {
            timestamp = Date(timeIntervalSince1970: ts / 1000)
        } else {
            timestamp = .now
        }

        // Get or use provided deviceId
        let effectiveDeviceId = deviceId ?? event.deviceId

        // Get device if we have an ID
        var device: Device?
        if let id = effectiveDeviceId {
            device = deviceManager.getOrCreateDevice(id: id)
        }

        let entry = LogEntry(
            timestamp: timestamp,
            level: level,
            source: source,
            logType: logType,
            message: event.message,
            metadata: metadataString,
            device: device
        )

        modelContext.insert(entry)
        save()

        logger.debug("Added \(logType.rawValue) log: \(event.message) [device: \(effectiveDeviceId ?? "none")]")
    }

    func addNetworkEvent(_ event: IncomingNetworkEvent) {
        switch event.stage {
        case .request:
            handleNetworkRequest(event)
        case .response:
            handleNetworkResponse(event)
        }
    }

    private func handleNetworkRequest(_ event: IncomingNetworkEvent) {
        let timestamp: Date
        if let ts = event.timestamp {
            timestamp = Date(timeIntervalSince1970: ts / 1000)
        } else {
            timestamp = .now
        }

        var headersString: String?
        if let headers = event.headers {
            if let data = try? JSONEncoder().encode(headers) {
                headersString = String(data: data, encoding: .utf8)
            }
        }

        var device: Device?
        if let deviceId = event.deviceId {
            device = deviceManager.getOrCreateDevice(id: deviceId)
        }

        let entry = NetworkEntry(
            timestamp: timestamp,
            method: event.method ?? "GET",
            url: event.url ?? "",
            requestHeaders: headersString,
            requestBody: event.body,
            isCompleted: false,
            device: device
        )

        modelContext.insert(entry)
        pendingNetworkRequests[event.requestId] = entry
        save()

        logger.debug("Added network request: \(event.url ?? "") [device: \(event.deviceId ?? "none")]")
    }

    private func handleNetworkResponse(_ event: IncomingNetworkEvent) {
        guard let entry = pendingNetworkRequests[event.requestId] else {
            logger.warning("No pending request found for ID: \(event.requestId)")
            return
        }

        var headersString: String?
        if let headers = event.headers {
            if let data = try? JSONEncoder().encode(headers) {
                headersString = String(data: data, encoding: .utf8)
            }
        }

        entry.statusCode = event.statusCode
        entry.duration = event.duration
        entry.responseHeaders = headersString
        entry.responseBody = event.body
        entry.isCompleted = true

        pendingNetworkRequests.removeValue(forKey: event.requestId)
        save()

        logger.debug("Completed network request: \(entry.url)")
    }

    func clearLogs() {
        do {
            try modelContext.delete(model: LogEntry.self)
            save()
            logger.info("Cleared all logs")
        } catch {
            logger.error("Failed to clear logs: \(error.localizedDescription)")
        }
    }

    func clearLogsForDevice(_ deviceId: String) {
        do {
            let descriptor = FetchDescriptor<LogEntry>(
                predicate: #Predicate { $0.device?.id == deviceId }
            )
            let logs = try modelContext.fetch(descriptor)
            for log in logs {
                modelContext.delete(log)
            }
            save()
            logger.info("Cleared \(logs.count) logs for device: \(deviceId)")
        } catch {
            logger.error("Failed to clear logs for device: \(error.localizedDescription)")
        }
    }

    func clearNetworkEntries() {
        do {
            try modelContext.delete(model: NetworkEntry.self)
            pendingNetworkRequests.removeAll()
            save()
            logger.info("Cleared all network entries")
        } catch {
            logger.error("Failed to clear network entries: \(error.localizedDescription)")
        }
    }

    func clearNetworkEntriesForDevice(_ deviceId: String) {
        do {
            let descriptor = FetchDescriptor<NetworkEntry>(
                predicate: #Predicate { $0.device?.id == deviceId }
            )
            let entries = try modelContext.fetch(descriptor)
            for entry in entries {
                modelContext.delete(entry)
            }
            
            pendingNetworkRequests = pendingNetworkRequests.filter { $0.value.device?.id != deviceId }
            save()
            logger.info("Cleared \(entries.count) network entries for device: \(deviceId)")
        } catch {
            logger.error("Failed to clear network entries for device: \(error.localizedDescription)")
        }
    }

    func clearAll() {
        clearLogs()
        clearNetworkEntries()
    }

    func clearAllForDevice(_ deviceId: String) {
        clearLogsForDevice(deviceId)
        clearNetworkEntriesForDevice(deviceId)
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save: \(error.localizedDescription)")
        }
    }
}
