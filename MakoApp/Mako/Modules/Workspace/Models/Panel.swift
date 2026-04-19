//
//  Panel.swift
//  Mako
//

import Foundation

struct Panel: Identifiable, Equatable {
    let id: UUID
    var tabs: [Tab]
    var activeTabId: UUID?

    init(tabs: [Tab] = []) {
        self.id = UUID()
        self.tabs = tabs
        self.activeTabId = tabs.first?.id
    }

    var activeTab: Tab? {
        guard let activeTabId else { return nil }
        return tabs.first { $0.id == activeTabId }
    }

    static func == (lhs: Panel, rhs: Panel) -> Bool {
        lhs.id == rhs.id
    }
}
