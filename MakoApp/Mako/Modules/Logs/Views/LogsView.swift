//
//  LogsView.swift
//  Mako
//

import SwiftUI

struct LogsView: View {
    @Bindable var viewModel: LogsViewModel

    var body: some View {
        VSplitView {
            VStack(spacing: 0) {
                filterBar
                Divider()
                logList
            }
            .frame(maxWidth: .infinity, minHeight: 200)

            if let selected = viewModel.selectedLog {
                LogDetailView(log: selected, onClose: {
                    viewModel.selectedLog = nil
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Subviews

    private var filterBar: some View {
        HStack(spacing: 12) {
            searchField
            levelPicker
            sourcePicker
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
            TextField("Search logs...", text: $viewModel.searchText)
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

    private var levelPicker: some View {
        Picker("Level", selection: $viewModel.selectedLevel) {
            Text("All Levels").tag(nil as LogLevel?)
            Divider()
            ForEach(LogLevel.allCases, id: \.self) { level in
                Label(level.rawValue.capitalized, systemImage: level.icon)
                    .tag(level as LogLevel?)
            }
        }
        .frame(width: 130)
    }

    private var sourcePicker: some View {
        Picker("Source", selection: $viewModel.selectedSource) {
            Text("All Sources").tag(nil as LogSource?)
            Divider()
            ForEach(LogSource.allCases, id: \.self) { source in
                Text(source.displayName).tag(source as LogSource?)
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
        Text("\(viewModel.filteredCount) logs")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var logList: some View {
        Group {
            if viewModel.hasFilteredLogs {
                List(viewModel.filteredLogs) { entry in
                    LogRowView(entry: entry)
                        .contentShape(Rectangle())
                        .listRowBackground(
                            viewModel.selectedLog?.id == entry.id
                                ? Color.accentColor.opacity(0.15)
                                : Color.clear
                        )
                        .onTapGesture {
                            viewModel.selectLog(entry)
                        }
                }
                .listStyle(.plain)
            } else {
                emptyState
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Logs", systemImage: "text.alignleft")
        } description: {
            if viewModel.hasLogs {
                Text("No logs match the current filters.")
            } else {
                Text("Logs will appear here when received from your React Native app.")
            }
        }
    }
}

#Preview {
    LogsView(viewModel: LogsViewModel(logs: [], deviceName: "Test Device"))
}
