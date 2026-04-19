//
//  NativeLogsView.swift
//  Mako
//

import SwiftUI

struct NativeLogsView: View {
    @Bindable var viewModel: NativeLogsViewModel

    var body: some View {
        VSplitView {
            VStack(spacing: 0) {
                filterBar
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

    private var filterBar: some View {
        HStack(spacing: 12) {
            platformBadge
            searchField
            levelPicker
            Spacer()
            deviceBadge
            countLabel
        }
        .padding()
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
        .clipShape(RoundedRectangle(cornerRadius: 6))
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

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search native logs...", text: $viewModel.searchText)
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

#Preview {
    NativeLogsView(viewModel: NativeLogsViewModel(
        logs: [],
        deviceName: "iPhone 15 Pro",
        platform: .ios
    ))
}
