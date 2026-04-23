//
//  SettingsView.swift
//  Mako
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("serverPort") private var serverPort: Int = 8765
    @AppStorage("autoClearOnConnect") private var autoClearOnConnect: Bool = true
    @AppStorage("showRightSidebar") private var showRightSidebar: Bool = true

    var body: some View {
        TabView {
            GeneralSettingsView(
                serverPort: $serverPort,
                autoClearOnConnect: $autoClearOnConnect,
                showRightSidebar: $showRightSidebar
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 450, height: 250)
    }
}
