//
//  LogsViewModel.swift
//  Mako
//

import Foundation
import Observation

@MainActor
@Observable
final class LogsViewModel {
    // MARK: - Dependencies

    private(set) var logs: [LogEntry]
    let deviceName: String?

    // MARK: - State

    var searchText = ""
    var selectedLevel: LogLevel?
    var selectedSource: LogSource?
    var selectedLog: LogEntry?

    // MARK: - Computed Properties

    var filteredLogs: [LogEntry] {
        logs.filter { entry in
            let matchesSearch = searchText.isEmpty ||
                entry.message.localizedStandardContains(searchText)
            let matchesLevel = selectedLevel == nil ||
                entry.logLevel == selectedLevel
            let matchesSource = selectedSource == nil ||
                entry.logSource == selectedSource
            return matchesSearch && matchesLevel && matchesSource
        }
    }

    var filteredCount: Int { filteredLogs.count }
    var totalCount: Int { logs.count }
    var hasLogs: Bool { !logs.isEmpty }
    var hasFilteredLogs: Bool { !filteredLogs.isEmpty }
    var hasActiveFilters: Bool {
        !searchText.isEmpty || selectedLevel != nil || selectedSource != nil
    }

    // MARK: - Init

    init(logs: [LogEntry], deviceName: String?) {
        self.logs = logs
        self.deviceName = deviceName
    }

    // MARK: - Actions

    func clearFilters() {
        searchText = ""
        selectedLevel = nil
        selectedSource = nil
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
