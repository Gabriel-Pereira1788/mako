//
//  MainView.swift
//  Mako
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: MainViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var searchText = ""
    @AppStorage("showRightSidebar") private var showRightSidebar = true

    private var isSidebarHidden: Bool {
        columnVisibility == .detailOnly
    }

    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: MainViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 280)
        } detail: {
            
            ZStack{
                VStack(spacing:10) {
                    CustomToolBar(viewModel: viewModel)

                    WorkspaceView(
                        workspaceState: viewModel.workspaceState,
                        deviceManager: viewModel.deviceManager,
                        filterManager: viewModel.filterManager
                    )
                    .background(AppStyle.Background.primary)
                }
                .padding(20)
                .offset(y: isSidebarHidden ? 30 : 0)
                .animation(reduceMotion ? .none : .spring(duration: 0.3), value: isSidebarHidden)
                
            }.toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea(edges:.top)
                
        }
        .background(AppStyle.Background.primary)
        .navigationTitle("")
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .focusedValue(\.appCommands, viewModel.makeCommandActions(toggleInspector: {
            showRightSidebar.toggle()
        }))
    }
}
