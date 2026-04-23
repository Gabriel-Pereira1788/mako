//
//  TabBarView.swift
//  Mako
//
//  Tab bar for a panel, similar to editor tabs
//

import SwiftUI

struct TabBarView: View {
    let tabs: [Tab]
    let activeTabId: UUID?
    let onSelectTab: (UUID) -> Void
    let onCloseTab: (UUID) -> Void
    var onCloseOtherTabs: ((UUID) -> Void)? = nil
    var onCloseTabsToRight: ((UUID) -> Void)? = nil
    var onMoveToNewPanel: ((UUID) -> Void)? = nil
    var canMoveToNewPanel: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        TabItemView(
                            tab: tab,
                            isActive: tab.id == activeTabId,
                            onSelect: { onSelectTab(tab.id) },
                            onClose: { onCloseTab(tab.id) },
                            onCloseOthers: tabs.count > 1 ? { onCloseOtherTabs?(tab.id) } : nil,
                            onCloseToRight: index < tabs.count - 1 ? { onCloseTabsToRight?(tab.id) } : nil,
                            onMoveToNewPanel: canMoveToNewPanel ? { onMoveToNewPanel?(tab.id) } : nil,
                            canMoveToNewPanel: canMoveToNewPanel
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            Spacer()
        }
        .frame(height: 36)
        .background(AppStyle.Background.secondary)
    }
}

