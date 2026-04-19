//
//  NetworkViewModel.swift
//  Mako
//

import Foundation
import Observation

@MainActor
@Observable
final class NetworkViewModel {
    // MARK: - Dependencies

    private(set) var entries: [NetworkEntry]
    let deviceName: String?

    // MARK: - State

    var searchText = ""
    var selectedMethod: String?
    var selectedEntry: NetworkEntry?

    // MARK: - Constants

    let availableMethods = ["GET", "POST", "PUT", "DELETE", "PATCH"]

    // MARK: - Computed Properties

    var filteredEntries: [NetworkEntry] {
        entries.filter { entry in
            let matchesSearch = searchText.isEmpty ||
                entry.url.localizedStandardContains(searchText)
            let matchesMethod = selectedMethod == nil ||
                entry.method.uppercased() == selectedMethod
            return matchesSearch && matchesMethod
        }
    }

    var filteredCount: Int { filteredEntries.count }
    var totalCount: Int { entries.count }
    var hasEntries: Bool { !entries.isEmpty }
    var hasFilteredEntries: Bool { !filteredEntries.isEmpty }
    var hasSelection: Bool { selectedEntry != nil }

    // MARK: - Init

    init(entries: [NetworkEntry], deviceName: String?) {
        self.entries = entries
        self.deviceName = deviceName
    }

    // MARK: - Actions

    func clearFilters() {
        searchText = ""
        selectedMethod = nil
    }

    func clearSearch() {
        searchText = ""
    }

    func selectEntry(_ entry: NetworkEntry?) {
        selectedEntry = entry
    }

    func updateEntries(_ newEntries: [NetworkEntry]) {
        entries = newEntries
    }
}
