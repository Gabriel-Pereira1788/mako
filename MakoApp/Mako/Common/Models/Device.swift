//
//  Device.swift
//  Mako
//
//  Represents a connected React Native device
//

import Foundation
import SwiftData

@Model
final class Device {
    @Attribute(.unique) var id: String
    var name: String
    var platform: String
    var appName: String
    var bundleId: String?
    var lastSeen: Date
    var isConnected: Bool

    @Relationship(deleteRule: .cascade, inverse: \LogEntry.device)
    var logs: [LogEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \NetworkEntry.device)
    var networkEntries: [NetworkEntry] = []

    init(
        id: String,
        name: String = "React Native",
        platform: DevicePlatform = .unknown,
        appName: String = "",
        bundleId: String? = nil,
        lastSeen: Date = .now,
        isConnected: Bool = true
    ) {
        self.id = id
        self.name = name
        self.platform = platform.rawValue
        self.appName = appName
        self.bundleId = bundleId
        self.lastSeen = lastSeen
        self.isConnected = isConnected
    }

    var devicePlatform: DevicePlatform {
        DevicePlatform(rawValue: platform) ?? .unknown
    }

    var displayName: String {
        if appName.isEmpty {
            return "\(name)"
        }
        return "\(appName) (\(name))"
    }
}
