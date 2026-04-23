//
//  NativeLogsView.swift
//  Mako
//

import SwiftUI

struct NativeLogsView: View {
    @Bindable var viewModel: NativeLogsViewModel
    @Bindable var filterContext: FilterContext

    private var filteredLogs: [LogEntry] {
        viewModel.logs.filter { entry in
            let matchesSearch = filterContext.searchText.isEmpty ||
                entry.message.localizedStandardContains(filterContext.searchText)
            let matchesLevel = filterContext.selectedLevel == nil ||
                entry.logLevel == filterContext.selectedLevel
            return matchesSearch && matchesLevel
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
                NativeLogDetailView(log: selected, onClose: {
                    viewModel.selectedLog = nil
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Subviews

    private var statusBar: some View {
        HStack(spacing: 12) {
            platformBadge
            Spacer()
            deviceBadge
            countLabel
        }
        .padding(.horizontal, AppStyle.Spacing.large)
        .padding(.vertical, AppStyle.Spacing.small)
    }

    private var platformBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.platformIcon)
            Text(viewModel.platformDisplayName)
        }
        .font(.caption)
        .bold()
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(platformBackgroundColor)
        .foregroundStyle(platformForegroundColor)
        .clipShape(.rect(cornerRadius: 6))
    }

    private var platformBackgroundColor: Color {
        switch viewModel.platform {
        case .ios: return Color.blue.opacity(0.2)
        case .android: return Color.green.opacity(0.2)
        case .unknown: return Color.gray.opacity(0.2)
        }
    }

    private var platformForegroundColor: Color {
        switch viewModel.platform {
        case .ios: return .blue
        case .android: return .green
        case .unknown: return .gray
        }
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
            Label("No Native Logs", systemImage: "apple.terminal")
        } description: {
            if viewModel.hasLogs {
                Text("No logs match the current filters.")
            } else {
                Text("Native logs from \(viewModel.platformDisplayName) will appear here.")
            }
        }
    }
}
