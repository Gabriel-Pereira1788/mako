//
//  NetworkContainerView.swift
//  Mako
//
//  Wrapper view for network entries with device filtering via SwiftData query
//

import SwiftUI
import SwiftData

struct NetworkContainerView: View {
    let device: Device?

    @Query private var allNetworkEntries: [NetworkEntry]
    @State private var viewModel: NetworkViewModel

    private var filteredEntries: [NetworkEntry] {
        guard let device else { return [] }
        return allNetworkEntries.filter { $0.device?.id == device.id }
            .sorted { $0.timestamp > $1.timestamp }
    }

    init(device: Device?) {
        self.device = device
        _viewModel = State(initialValue: NetworkViewModel(entries: [], deviceName: device?.name))
    }

    var body: some View {
        NetworkView(viewModel: viewModel)
            .task {
                viewModel.updateEntries(filteredEntries)
            }
            .onChange(of: filteredEntries) { _, newEntries in
                viewModel.updateEntries(newEntries)
            }
    }
}

// MARK: - Type Alias for backwards compatibility
typealias NetworkContentView = NetworkContainerView
