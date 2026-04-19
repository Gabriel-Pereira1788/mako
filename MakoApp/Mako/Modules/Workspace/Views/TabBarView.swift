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

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(tabs) { tab in
                        TabItemView(
                            tab: tab,
                            isActive: tab.id == activeTabId,
                            onSelect: { onSelectTab(tab.id) },
                            onClose: { onCloseTab(tab.id) }
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            Spacer()
        }
        .frame(height: 36)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

