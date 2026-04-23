//
//  GeneralSettingsView.swift
//  Mako
//
//  General settings form
//

import SwiftUI

struct GeneralSettingsView: View {
    @Binding var serverPort: Int
    @Binding var autoClearOnConnect: Bool
    @Binding var showRightSidebar: Bool

    var body: some View {
        Form {
            Section {
                TextField("WebSocket Port", value: $serverPort, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    .help("Port for the WebSocket server (requires restart)")
            } header: {
                Text("Server")
            }

            Section {
                Toggle("Clear logs when device connects", isOn: $autoClearOnConnect)
                    .help("Automatically clear logs when a new device connects")

                Toggle("Show Inspector sidebar by default", isOn: $showRightSidebar)
                    .help("Show the right sidebar with quick actions when the app starts")
            } header: {
                Text("Behavior")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
