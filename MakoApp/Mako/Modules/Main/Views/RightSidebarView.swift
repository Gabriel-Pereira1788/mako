//
//  RightSidebarView.swift
//  Mako
//
//  Right sidebar with quick actions
//

import SwiftUI

struct RightSidebarView: View {
    let selectedDevice: Device?
    let canSplit: Bool
    let onAddTab: (TabType) -> Void
    let onSplit: (SplitDirection) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Actions")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, AppStyle.Spacing.extraLarge)
            .padding(.vertical, AppStyle.Spacing.large)

            Divider()

            ScrollView {
                VStack(spacing: AppStyle.Spacing.extraLarge) {
                    // Open tabs section
                    if selectedDevice != nil {
                        openTabsSection
                    }

                    // Split section
                    if canSplit {
                        splitSection
                    }

                    Spacer()
                }
                .padding(AppStyle.Spacing.extraLarge)
            }
        }
    }

    private var openTabsSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.Spacing.medium) {
            Text("Open Tab")
                .font(.caption)
                .foregroundStyle(.tertiary)

            ActionButton(
                title: "JS Logs",
                icon: "text.alignleft",
                color: .blue
            ) {
                onAddTab(.logs)
            }

            ActionButton(
                title: "Network",
                icon: "network",
                color: .green
            ) {
                onAddTab(.network)
            }

            ActionButton(
                title: "Native Logs",
                icon: "apple.terminal",
                color: .purple
            ) {
                onAddTab(.nativeLogs)
            }
        }
    }

    private var splitSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.Spacing.medium) {
            Text("Split Panel")
                .font(.caption)
                .foregroundStyle(.tertiary)

            ActionButton(
                title: "Split Horizontal",
                icon: "rectangle.split.1x2",
                color: .orange
            ) {
                onSplit(.horizontal)
            }

            ActionButton(
                title: "Split Vertical",
                icon: "rectangle.split.2x1",
                color: .purple
            ) {
                onSplit(.vertical)
            }
        }
    }
}

