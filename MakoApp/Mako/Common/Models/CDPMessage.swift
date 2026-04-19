//
//  CDPMessage.swift
//  Mako
//
//  Chrome DevTools Protocol message types for Metro connection
//

import Foundation

// MARK: - Target Discovery

/// Represents a debuggable target returned by /json/list
struct CDPTarget: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let type: String?
    let url: String?
    let webSocketDebuggerUrl: String?
    let devtoolsFrontendUrl: String?
    let faviconUrl: String?
    let vm: String?

    var displayName: String {
        if let vm = vm, !vm.isEmpty {
            return "\(title) (\(vm))"
        }
        return title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CDPTarget, rhs: CDPTarget) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - CDP Messages

/// Outgoing CDP request
struct CDPRequest: Encodable {
    let id: Int
    let method: String
    let params: [String: AnyCodable]?

    init(id: Int, method: String, params: [String: AnyCodable]? = nil) {
        self.id = id
        self.method = method
        self.params = params
    }
}

/// Incoming CDP response
struct CDPResponse: Decodable {
    let id: Int?
    let result: [String: AnyCodable]?
    let error: CDPError?
}

struct CDPError: Decodable {
    let code: Int
    let message: String
}

/// Incoming CDP event (no id, has method)
struct CDPEvent: Decodable {
    let method: String
    let params: CDPEventParams?
}

// MARK: - Runtime.consoleAPICalled Event

struct CDPEventParams: Decodable {
    // For Runtime.consoleAPICalled
    let type: String?
    let args: [CDPRemoteObject]?
    let timestamp: Double?
    let stackTrace: CDPStackTrace?

    // For Runtime.exceptionThrown
    let exceptionDetails: CDPExceptionDetails?

    // For Network events
    let requestId: String?
    let request: CDPNetworkRequest?
    let response: CDPNetworkResponse?
    let encodedDataLength: Int?
}

// MARK: - Network Types

struct CDPNetworkRequest: Decodable {
    let url: String
    let method: String
    let headers: [String: String]?
    let postData: String?
    let hasPostData: Bool?
}

struct CDPNetworkResponse: Decodable {
    let url: String
    let status: Int
    let statusText: String?
    let headers: [String: String]?
    let mimeType: String?
    let connectionReused: Bool?
    let connectionId: Int?
    let encodedDataLength: Int?
}

struct CDPRemoteObject: Decodable {
    let type: String
    let subtype: String?
    let value: AnyCodable?
    let description: String?
    let className: String?
    let preview: CDPObjectPreview?

    var stringValue: String {
        if let description = description {
            return description
        }
        if let value = value?.value {
            if let str = value as? String {
                return str
            }
            if let num = value as? NSNumber {
                return num.stringValue
            }
            if let bool = value as? Bool {
                return bool ? "true" : "false"
            }
            return String(describing: value)
        }
        return "[\(type)]"
    }
}

struct CDPObjectPreview: Decodable {
    let type: String
    let subtype: String?
    let description: String?
    let overflow: Bool?
    let properties: [CDPPropertyPreview]?
}

struct CDPPropertyPreview: Decodable {
    let name: String
    let type: String
    let value: String?
}

struct CDPStackTrace: Decodable {
    let callFrames: [CDPCallFrame]
}

struct CDPCallFrame: Decodable {
    let functionName: String
    let url: String
    let lineNumber: Int
    let columnNumber: Int
}

struct CDPExceptionDetails: Decodable {
    let text: String
    let lineNumber: Int?
    let columnNumber: Int?
    let url: String?
    let exception: CDPRemoteObject?
}

// MARK: - Message Parsing

enum CDPMessage {
    case response(CDPResponse)
    case event(CDPEvent)
    case unknown

    static func parse(from data: Data) -> CDPMessage {
        let decoder = JSONDecoder()

        // Try to decode as event first (has method, no id)
        if let event = try? decoder.decode(CDPEvent.self, from: data),
           !event.method.isEmpty {
            return .event(event)
        }

        // Try to decode as response (has id)
        if let response = try? decoder.decode(CDPResponse.self, from: data),
           response.id != nil {
            return .response(response)
        }

        return .unknown
    }
}

// MARK: - Console Type Mapping

extension CDPEventParams {
    var logLevel: LogLevel {
        switch type {
        case "warning": return .warn
        case "error": return .error
        case "debug": return .debug
        default: return .info
        }
    }

    var logMessage: String {
        guard let args = args else { return "" }
        return args.map { $0.stringValue }.joined(separator: " ")
    }
}
