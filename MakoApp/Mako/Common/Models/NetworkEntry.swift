//
//  NetworkEntry.swift
//  Mako
//

import Foundation
import SwiftData

@Model
final class NetworkEntry {
    var id: UUID
    var timestamp: Date
    var method: String
    var url: String
    var statusCode: Int?
    var duration: Double?
    var requestHeaders: String?
    var requestBody: String?
    var responseHeaders: String?
    var responseBody: String?
    var isCompleted: Bool

    @Relationship var device: Device?

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        method: String,
        url: String,
        statusCode: Int? = nil,
        duration: Double? = nil,
        requestHeaders: String? = nil,
        requestBody: String? = nil,
        responseHeaders: String? = nil,
        responseBody: String? = nil,
        isCompleted: Bool = false,
        device: Device? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.method = method
        self.url = url
        self.statusCode = statusCode
        self.duration = duration
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.isCompleted = isCompleted
        self.device = device
    }

}
