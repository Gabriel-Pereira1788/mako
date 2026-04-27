//
//  NetworkView.swift
//  Mako
//

import SwiftUI

struct NetworkView: View {
    @Bindable var viewModel: NetworkViewModel
    @Bindable var filterContext: FilterContext
    @Environment(\.soundManager) private var soundManager

    private var filteredEntries: [NetworkEntry] {
        viewModel.entries.filter { entry in
            let matchesSearch = filterContext.searchText.isEmpty ||
                entry.url.localizedStandardContains(filterContext.searchText)
            let matchesMethod = filterContext.selectedMethod == nil ||
                entry.method.uppercased() == filterContext.selectedMethod
            return matchesSearch && matchesMethod
        }
    }

    var body: some View {
        VSplitView {
            VStack(spacing: 0) {
                statusBar
                Divider()
                networkList
            }
            .frame(maxWidth:.infinity, minHeight: 200)

            if let selected = viewModel.selectedEntry {
                NetworkDetailView(
                    viewModel: NetworkDetailViewModel(entry: selected),
                    onClose: { viewModel.selectedEntry = nil }
                )
            }
        }
        .frame(maxWidth:.infinity ,maxHeight: .infinity)
    }

    // MARK: - Subviews

    private var statusBar: some View {
        HStack(spacing: 12) {
            Spacer()
            deviceBadge
            countLabel
        }
        .padding(.horizontal, AppStyle.Spacing.large)
        .padding(.vertical, AppStyle.Spacing.small)
    }

    @ViewBuilder
    private var deviceBadge: some View {
        if let deviceName = viewModel.deviceName {
            Text(deviceName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .clipShape(Capsule())
        }
    }

    private var countLabel: some View {
        Text("\(filteredEntries.count) requests")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var networkList: some View {
        Group {
            if !filteredEntries.isEmpty {
                List(filteredEntries) { entry in
                    NetworkRowView(entry: entry)
                        .contentShape(Rectangle())
                        .listRowBackground(
                            viewModel.selectedEntry?.id == entry.id
                                ? Color.accentColor.opacity(0.15)
                                : Color.clear
                        )
                        .onTapGesture {
                            viewModel.selectEntry(entry)
                            soundManager?.playDetailClick()
                        }
                }
                .listStyle(.plain)
                .frame(minWidth:400)
            } else {
                emptyState
            }
        }
        .frame(minWidth:400,maxWidth:.infinity,maxHeight: .infinity)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Requests", systemImage: "network")
        } description: {
            if viewModel.hasEntries {
                Text("No requests match the current filters.")
            } else {
                Text("Network requests will appear here when captured from your React Native app.")
            }
        }
    }
}

