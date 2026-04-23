//
//  LogsView.swift
//  Mako
//

import SwiftUI

struct LogsView: View {
    @Bindable var viewModel: LogsViewModel
    @Bindable var filterContext: FilterContext

    private var filteredLogs: [LogEntry] {
        viewModel.logs.filter { entry in
            let matchesSearch = filterContext.searchText.isEmpty ||
                entry.message.localizedStandardContains(filterContext.searchText)
            let matchesLevel = filterContext.selectedLevel == nil ||
                entry.logLevel == filterContext.selectedLevel
            let matchesSource = filterContext.selectedSource == nil ||
                entry.logSource == filterContext.selectedSource
            return matchesSearch && matchesLevel && matchesSource
        }
    }

    var body: some View {
        VSplitView {
            VStack(spacing: 0) {
                statusBar
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
        Text("\(filteredLogs.count) logs")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var logList: some View {
        Group {
            if !filteredLogs.isEmpty {
                List(filteredLogs) { entry in
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
