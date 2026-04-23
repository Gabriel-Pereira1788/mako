//
//  FilterManager.swift
//  Mako
//
//  Manages filter contexts for each tab, preserving state when switching tabs
//

import Foundation
import Observation

@MainActor
@Observable
final class FilterManager {
    // MARK: - Properties

    private var contexts: [UUID: FilterContext] = [:]

    // MARK: - Public Methods

    func context(for tab: Tab) -> FilterContext {
        if let existing = contexts[tab.id] {
            return existing
        }
        let newContext = FilterContext(tabType: tab.type)
        contexts[tab.id] = newContext
        return newContext
    }

    func removeContext(for tabId: UUID) {
        contexts.removeValue(forKey: tabId)
    }

    func clearAllContexts() {
        contexts.removeAll()
    }
}
