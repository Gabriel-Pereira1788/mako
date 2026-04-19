//
//  NativeLogsViewModel.swift
//  Mako
//

import Foundation
import Observation

@MainActor
@Observable
final class NativeLogsViewModel {
    // MARK: - Dependencies

    private(set) var logs: [LogEntry]
    let deviceName: String?
    let platform: DevicePlatform

    // MARK: - State

    var searchText = ""
    var selectedLevel: LogLevel?
    var selectedLog: LogEntry?

    // MARK: - Computed Properties

    var filteredLogs: [LogEntry] {
        logs.filter { entry in
            let matchesSearch = searchText.isEmpty ||
                entry.message.localizedStandardContains(searchText)
            let matchesLevel = selectedLevel == nil ||
                entry.logLevel == selectedLevel
            return matchesSearch && matchesLevel
        }
    }

    var filteredCount: Int { filteredLogs.count }
    var totalCount: Int { logs.count }
    var hasLogs: Bool { !logs.isEmpty }
    var hasFilteredLogs: Bool { !filteredLogs.isEmpty }
    var hasActiveFilters: Bool {
        !searchText.isEmpty || selectedLevel != nil
    }

    var platformDisplayName: String {
        switch platform {
        case .ios: return "iOS Native"
        case .android: return "Android Native"
        case .unknown: return "Native"
        }
    }

    var platformIcon: String {
        switch platform {
        case .ios: return "apple.logo"
        case .android: return "cpu"
        case .unknown: return "questionmark.circle"
        }
    }

    var platformColor: String {
        switch platform {
        case .ios: return "blue"
        case .android: return "green"
        case .unknown: return "gray"
        }
    }

    // MARK: - Init

    init(logs: [LogEntry], deviceName: String?, platform: DevicePlatform) {
        self.logs = logs
        self.deviceName = deviceName
        self.platform = platform
    }

    // MARK: - Actions

    func clearFilters() {
        searchText = ""
        selectedLevel = nil
    }

    func clearSearch() {
        searchText = ""
    }

    func selectLog(_ log: LogEntry?) {
        selectedLog = log
    }

    func updateLogs(_ newLogs: [LogEntry]) {
        logs = newLogs
    }
}
