//
//  Tab.swift
//  Mako
//

import Foundation

struct Tab: Identifiable, Equatable {
    let id: UUID
    let type: TabType
    let deviceId: String

    init(type: TabType, deviceId: String) {
        self.id = UUID()
        self.type = type
        self.deviceId = deviceId
    }

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
}
