//
//  MainView.swift
//  Mako
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var server: WebSocketServer
    @State private var deviceManager: DeviceManager
    @State private var logStore: LogStore
    
    @State private var workspaceState = WorkspaceState()
    @State private var selectedDevice: Device?
    @State private var showLeftSidebar = true
    @State private var showRightSidebar = true
    
    init(modelContext: ModelContext) {
        let deviceManager = DeviceManager(modelContext: modelContext)
        _deviceManager = State(wrappedValue: deviceManager)
        _logStore = State(wrappedValue: LogStore(modelContext: modelContext, deviceManager: deviceManager))
        _server = State(wrappedValue: WebSocketServer())
    }
    
    var body: some View {
        HSplitView {
            if showLeftSidebar {
                leftSidebar
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            }
            
            WorkspaceView(
                workspaceState: workspaceState,
                deviceManager: deviceManager
            )
            .frame(minWidth: 600)
            .background(Color(.windowBackgroundColor))
            
            if showRightSidebar {
                RightSidebarView(
                    selectedDevice: selectedDevice,
                    canSplit: workspaceState.canSplit,
                    onAddTab: { tabType in
                        if let device = selectedDevice {
                            workspaceState.addTab(type: tabType, deviceId: device.id)
                        }
                    },
                    onSplit: { direction in
                        workspaceState.splitDirection = direction
                        _ = workspaceState.addPanel()
                    }
                ).background(Color(.windowBackgroundColor))
                
            }
        }
        .background {
            WindowAccessor { window in
                configureWindow(window)
            }
        }
        .toolbar {
            toolbarContent
        }
        .navigationTitle("")
        .onAppear {
            setupCallbacks()
            server.start()
        }
        .onDisappear {
            for device in deviceManager.connectedDevices {
                logStore.clearAllForDevice(device.id)
            }
            server.stop()
        }
        .onChange(of: selectedDevice) { _, newDevice in
            if let device = newDevice {
                workspaceState.openDeviceTabs(deviceId: device.id)
            }
        }
    }
    
    // MARK: - Left Sidebar
    
    private var leftSidebar: some View {
        VStack(spacing: 0) {
            DeviceListView(
                devices: deviceManager.devices,
                selectedDevice: $selectedDevice,
                onClearDevice: { device in
                    logStore.clearAllForDevice(device.id)
                }
            )
            
            Divider()
            
            connectionStatus
        }
        .background(.regularMaterial)
    }
    
    private var connectionStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            serverStatus
        }
        .padding()
    }
    
    private var serverStatus: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("WebSocket")
                    .font(.caption)
                    .bold()
                
                Spacer()
                
                Circle()
                    .fill(server.isRunning ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(server.isRunning ? "Port \(server.port)" : "Offline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if server.isRunning {
                Text("\(server.connectedClients) client(s)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            if let error = server.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button("Toggle Left Sidebar", systemImage: "sidebar.left") {
                showLeftSidebar.toggle()
            }
            .labelStyle(.iconOnly)
            .help("Toggle Left Sidebar")
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button("Toggle Right Sidebar", systemImage: "sidebar.right") {
                showRightSidebar.toggle()
            }
            .labelStyle(.iconOnly)
            .help("Toggle Right Sidebar")
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button("Clear Logs", systemImage: "trash") {
                if let device = selectedDevice {
                    logStore.clearAllForDevice(device.id)
                } else {
                    logStore.clearAll()
                }
            }
            .labelStyle(.iconOnly)
            .help("Clear Logs")
        }
    }
    
    // MARK: - Callbacks
    
    private func setupCallbacks() {
        server.onDeviceConnected = { deviceInfo in
            logStore.clearAllForDevice(deviceInfo.deviceId)

            let platform: DevicePlatform
            switch deviceInfo.platform.lowercased() {
            case "ios":
                platform = .ios
            case "android":
                platform = .android
            default:
                platform = .unknown
            }

            _ = deviceManager.getOrCreateDevice(
                id: deviceInfo.deviceId,
                name: deviceInfo.deviceName,
                platform: platform,
                appName: deviceInfo.appName,
                bundleId: deviceInfo.bundleId
            )
        }
        
        server.onDeviceDisconnected = { deviceId in
            deviceManager.markDisconnected(id: deviceId)
        }
        
        server.onNetworkReceived = { event in
            logStore.addNetworkEvent(event)
        }
        
        server.onLogReceived = { event in
            logStore.addLog(event)
        }
    }
    
    private func configureWindow(_ window: NSWindow) {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
    }
}
