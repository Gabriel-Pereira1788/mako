//
//  NetworkView.swift
//  Mako
//

import SwiftUI

struct NetworkView: View {
    @Bindable var viewModel: NetworkViewModel

    var body: some View {
        VSplitView {
            VStack(spacing: 0) {
                filterBar
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

    private var filterBar: some View {
        HStack(spacing: 12) {
            searchField
            methodPicker
            Spacer()
            deviceBadge
            countLabel
        }
        .padding()
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search URLs...", text: $viewModel.searchText)
                .textFieldStyle(.plain)

            if !viewModel.searchText.isEmpty {
                Button("Clear Search", systemImage: "xmark.circle.fill") {
                    viewModel.clearSearch()
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var methodPicker: some View {
        Picker("Method", selection: $viewModel.selectedMethod) {
            Text("All Methods").tag(nil as String?)
            Divider()
            ForEach(viewModel.availableMethods, id: \.self) { method in
                Text(method).tag(method as String?)
            }
        }
        .frame(width: 130)
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
        Text("\(viewModel.filteredCount) requests")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var networkList: some View {
        Group {
            if viewModel.hasFilteredEntries {
                List(viewModel.filteredEntries) { entry in
                    NetworkRowView(entry: entry)
                        .contentShape(Rectangle())
                        .listRowBackground(
                            viewModel.selectedEntry?.id == entry.id
                                ? Color.accentColor.opacity(0.15)
                                : Color.clear
                        )
                        .onTapGesture {
                            viewModel.selectEntry(entry)
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

