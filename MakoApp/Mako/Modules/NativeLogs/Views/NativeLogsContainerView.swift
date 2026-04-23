//
//  NativeLogsContainerView.swift
//  Mako
//
//  Wrapper view for native logs with device filtering via SwiftData query
//

import SwiftUI
import SwiftData

struct NativeLogsContainerView: View {
    let device: Device?
    let filterContext: FilterContext

    @Query private var allLogs: [LogEntry]
    @State private var viewModel: NativeLogsViewModel

    private var filteredLogs: [LogEntry] {
        guard let device else { return [] }

        return allLogs
            .filter { $0.device?.id == device.id && $0.entryLogType == .native }
            .sorted { $0.timestamp > $1.timestamp }
    }

    init(device: Device?, filterContext: FilterContext) {
        self.device = device
        self.filterContext = filterContext
        _viewModel = State(initialValue: NativeLogsViewModel(
            logs: [],
            deviceName: device?.name,
            platform: device?.devicePlatform ?? .unknown
        ))
    }

    var body: some View {
        NativeLogsView(viewModel: viewModel, filterContext: filterContext)
            .task {
                viewModel.updateLogs(filteredLogs)
            }
            .onChange(of: filteredLogs) { _, newLogs in
                viewModel.updateLogs(newLogs)
            }
    }
}

// MARK: - Type Alias for compatibility
typealias NativeLogsContentView = NativeLogsContainerView
