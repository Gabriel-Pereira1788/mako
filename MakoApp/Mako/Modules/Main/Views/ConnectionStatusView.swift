//
//  ConnectionStatusView.swift
//  Mako
//
//  Displays WebSocket server connection status
//

import SwiftUI

struct ConnectionStatusView: View {
    let server: WebSocketServer

    var body: some View {
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
}
