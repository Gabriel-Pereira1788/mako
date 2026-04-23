//
//  CustomToolbar.swift
//  Mako
//
//  Dynamic toolbar with context-aware filters based on active tab
//

import SwiftUI

struct CustomToolBar: View {
    @Bindable var viewModel: MainViewModel

    var body: some View {
        HStack(spacing: 10) {
            if let context = viewModel.activeFilterContext {
                ToolbarContent(
                    context: context,
                    platform: viewModel.activeDevicePlatform,
                    isDeviceSelected: viewModel.selectedDevice != nil,
                    onClearLogs: { viewModel.clearCurrentLogs() }
                )
            }
        }
    }
}

// MARK: - Toolbar Content

private struct ToolbarContent: View {
    @Bindable var context: FilterContext
    let platform: DevicePlatform
    let isDeviceSelected: Bool
    let onClearLogs: () -> Void

    var body: some View {
        dynamicFilters

        Spacer()

        TextField(context.searchPlaceholder, text: $context.searchText)
            .textFieldStyle(.roundedBorder)
            .frame(minWidth: 300, maxWidth: .infinity)

        Spacer()

        Button("Clear Logs", systemImage: "trash", action: onClearLogs)
            .labelStyle(.iconOnly)
            .help("Clear Logs (Cmd+K)")
            .disabled(!isDeviceSelected)
    }

    @ViewBuilder
    private var dynamicFilters: some View {
        switch context.tabType {
        case .logs:
            LogsFilterPicker(context: context)
        case .network:
            NetworkFilterPicker(context: context)
        case .nativeLogs:
            NativeLogsFilterPicker(context: context, platform: platform)
        }
    }
}
