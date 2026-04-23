//
//  FilterContext.swift
//  Mako
//
//  Filter state context for each tab, allowing unified toolbar with dynamic filters
//

import Foundation
import Observation

@MainActor
@Observable
final class FilterContext {
    // MARK: - Properties

    let tabType: TabType

    // Common
    var searchText: String = ""

    // Logs & NativeLogs
    var selectedLevel: LogLevel?
    var selectedSource: LogSource?

    // Network
    var selectedMethod: String?

    // MARK: - Constants

    static let availableMethods = ["GET", "POST", "PUT", "DELETE", "PATCH"]

    // MARK: - Init

    init(tabType: TabType) {
        self.tabType = tabType
    }

    // MARK: - Computed

    var hasActiveFilters: Bool {
        switch tabType {
        case .logs:
            return !searchText.isEmpty || selectedLevel != nil || selectedSource != nil
        case .network:
            return !searchText.isEmpty || selectedMethod != nil
        case .nativeLogs:
            return !searchText.isEmpty || selectedLevel != nil
        }
    }

    var searchPlaceholder: String {
        switch tabType {
        case .logs: return "Search logs..."
        case .network: return "Search URLs..."
        case .nativeLogs: return "Search native logs..."
        }
    }

    // MARK: - Actions

    func clearFilters() {
        searchText = ""
        selectedLevel = nil
        selectedSource = nil
        selectedMethod = nil
    }

    func clearSearch() {
        searchText = ""
    }
}
