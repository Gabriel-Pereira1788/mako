//
//  IncomingEvent.swift
//  Mako
//

import Foundation

struct IncomingEvent: Codable {
    let type: EventType
    let timestamp: Double?

    enum EventType: String, Codable {
        case log
        case network
        case native  // Native platform logs (iOS/Android)
    }
}

struct IncomingLogEvent: Codable {
    let type: String
    let source: String
    let level: String
    let message: String
    let timestamp: Double?
    let metadata: [String: AnyCodable]?
    var deviceId: String?
}

struct IncomingNetworkEvent: Codable {
    let type: String
    let stage: NetworkStage
    let requestId: String
    let method: String?
    let url: String?
    let statusCode: Int?
    let duration: Double?
    let headers: [String: String]?
    let body: String?
    let timestamp: Double?
    var deviceId: String?

    enum NetworkStage: String, Codable {
        case request
        case response
    }
}

// Helper for handling arbitrary JSON values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
