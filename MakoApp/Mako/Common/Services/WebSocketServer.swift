//
//  WebSocketServer.swift
//  Mako
//

import Foundation
import Observation
import Network
import OSLog

/// Device info received from SDK
struct DeviceInfo: Codable {
    let type: String  // "device_info"
    let deviceId: String
    let deviceName: String
    let platform: String
    let appName: String?
    let bundleId: String?
}

@MainActor
@Observable
final class WebSocketServer {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private var connectionDeviceMap: [ObjectIdentifier: String] = [:]  // connection -> deviceId
    let port: UInt16
    private let logger = Logger(subsystem: "com.rntrace", category: "WebSocket")

    var isRunning = false
    var connectedClients = 0
    var lastError: String?

    var onLogReceived: ((IncomingLogEvent) -> Void)?
    var onNetworkReceived: ((IncomingNetworkEvent) -> Void)?
    var onDeviceConnected: ((DeviceInfo) -> Void)?
    var onDeviceDisconnected: ((String) -> Void)?  // deviceId

    init(port: UInt16 = 8765) {
        self.port = port
    }

    func start() {
        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            let wsOptions = NWProtocolWebSocket.Options()
            wsOptions.autoReplyPing = true

            parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

            listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
            listener?.stateUpdateHandler = { [weak self] state in
                Task { @MainActor in
                    self?.handleListenerState(state)
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                Task { @MainActor in
                    self?.handleNewConnection(connection)
                }
            }

            listener?.start(queue: .main)
            logger.info("WebSocket server starting on port \(self.port)")
        } catch {
            logger.error("Failed to start server: \(error.localizedDescription)")
            lastError = error.localizedDescription
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
        connections.forEach { $0.cancel() }
        connections.removeAll()
        connectionDeviceMap.removeAll()
        isRunning = false
        connectedClients = 0
        logger.info("WebSocket server stopped")
    }

    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            isRunning = true
            lastError = nil
            logger.info("Server ready on port \(self.port)")
        case .failed(let error):
            isRunning = false
            lastError = error.localizedDescription
            logger.error("Server failed: \(error.localizedDescription)")
        case .cancelled:
            isRunning = false
            logger.info("Server cancelled")
        default:
            break
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        connections.append(connection)
        connectedClients = connections.count
        logger.info("New client connected. Total: \(self.connections.count)")

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                self?.handleConnectionState(connection, state: state)
            }
        }

        connection.start(queue: .main)
        receiveMessage(from: connection)
    }

    private func handleConnectionState(_ connection: NWConnection, state: NWConnection.State) {
        switch state {
        case .ready:
            logger.info("Client connection ready")
        case .failed(let error):
            logger.error("Client connection failed: \(error.localizedDescription)")
            removeConnection(connection)
        case .cancelled:
            logger.info("Client disconnected")
            removeConnection(connection)
        default:
            break
        }
    }

    private func removeConnection(_ connection: NWConnection) {
        let connectionId = ObjectIdentifier(connection)
        if let deviceId = connectionDeviceMap[connectionId] {
            connectionDeviceMap.removeValue(forKey: connectionId)
            onDeviceDisconnected?(deviceId)
            logger.info("Device disconnected: \(deviceId)")
        }
        connections.removeAll { $0 === connection }
        connectedClients = connections.count
    }

    private func receiveMessage(from connection: NWConnection) {
        connection.receiveMessage { [weak self] content, context, isComplete, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    self.logger.error("Receive error: \(error.localizedDescription)")
                    return
                }

                if let content = content, let context = context {
                    self.handleMessage(content, context: context, from: connection)
                }

                if connection.state == .ready {
                    self.receiveMessage(from: connection)
                }
            }
        }
    }

    private func handleMessage(_ data: Data, context: NWConnection.ContentContext, from connection: NWConnection) {
        guard let metadata = context.protocolMetadata.first as? NWProtocolWebSocket.Metadata else {
            return
        }

        switch metadata.opcode {
        case .text:
            handleTextMessage(data, from: connection)
        case .binary:
            handleTextMessage(data, from: connection)
        case .close:
            connection.cancel()
        default:
            break
        }
    }

    private func handleTextMessage(_ data: Data, from connection: NWConnection) {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            logger.error("Failed to decode message as UTF-8")
            return
        }

        logger.debug("Received: \(jsonString)")

        do {
            let decoder = JSONDecoder()

            // Check if it's a device_info message first
            if let deviceInfo = try? decoder.decode(DeviceInfo.self, from: data),
               deviceInfo.type == "device_info" {
                handleDeviceInfo(deviceInfo, from: connection)
                return
            }

            // Get deviceId for this connection
            let connectionId = ObjectIdentifier(connection)
            let deviceId = connectionDeviceMap[connectionId]

            // Determine the event type
            let baseEvent = try decoder.decode(IncomingEvent.self, from: data)

            switch baseEvent.type {
            case .log:
                var logEvent = try decoder.decode(IncomingLogEvent.self, from: data)
                logEvent.deviceId = deviceId
                logger.debug("Log event received: \(logEvent.message)")
                onLogReceived?(logEvent)
            case .network:
                var networkEvent = try decoder.decode(IncomingNetworkEvent.self, from: data)
                networkEvent.deviceId = deviceId
                onNetworkReceived?(networkEvent)
            case .native:
                var logEvent = try decoder.decode(IncomingLogEvent.self, from: data)
                logEvent.deviceId = deviceId
                logger.debug("Native log event received: \(logEvent.message)")
                onLogReceived?(logEvent)
            }
        } catch {
            logger.error("Failed to parse message: \(error.localizedDescription)")
        }
    }

    private func handleDeviceInfo(_ deviceInfo: DeviceInfo, from connection: NWConnection) {
        let connectionId = ObjectIdentifier(connection)
        connectionDeviceMap[connectionId] = deviceInfo.deviceId
        onDeviceConnected?(deviceInfo)
        logger.info("Device registered: \(deviceInfo.deviceName) (\(deviceInfo.deviceId))")
    }

    func broadcast(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }

        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(
            identifier: "textMessage",
            metadata: [metadata]
        )

        for connection in connections where connection.state == .ready {
            connection.send(
                content: data,
                contentContext: context,
                isComplete: true,
                completion: .idempotent
            )
        }
    }
}
