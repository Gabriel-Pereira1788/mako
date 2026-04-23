//
//  LogsContainerView.swift
//  Mako
//
//  Wrapper view for logs with device filtering via SwiftData query
//

import SwiftUI
import SwiftData

struct LogsContainerView: View {
    let device: Device?
    let filterContext: FilterContext

    @Query private var allLogs: [LogEntry]
    @State private var viewModel: LogsViewModel

    private var filteredLogs: [LogEntry] {
        guard let device else { return [] }
        return allLogs
            .filter { $0.device?.id == device.id && $0.entryLogType == .log }
            .sorted { $0.timestamp > $1.timestamp }
    }

    init(device: Device?, filterContext: FilterContext) {
        self.device = device
        self.filterContext = filterContext
        _viewModel = State(initialValue: LogsViewModel(logs: [], deviceName: device?.name))
    }

    var body: some View {
        LogsView(viewModel: viewModel, filterContext: filterContext)
            .task {
                viewModel.updateLogs(filteredLogs)
            }
            .onChange(of: filteredLogs) { _, newLogs in
                viewModel.updateLogs(newLogs)
            }
    }
}

// MARK: - Type Alias for backwards compatibility
typealias LogsContentView = LogsContainerView
