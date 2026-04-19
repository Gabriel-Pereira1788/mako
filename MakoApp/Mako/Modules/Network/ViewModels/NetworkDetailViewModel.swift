//
//  NetworkDetailViewModel.swift
//  Mako
//

import Foundation
import Observation
import AppKit

enum NetworkDetailTab {
    case request
    case response
}

@MainActor
@Observable
final class NetworkDetailViewModel {
    // MARK: - Dependencies

    let entry: NetworkEntry

    // MARK: - State

    var selectedTab: NetworkDetailTab = .request

    // MARK: - Computed Properties

    var methodDisplay: String {
        entry.method.uppercased()
    }

    var statusCode: Int? {
        entry.statusCode
    }

    var durationDisplay: String? {
        guard let duration = entry.duration else { return nil }
        return String(format: "%.2fms", duration)
    }

    var formattedRequestHeaders: String? {
        guard let headers = entry.requestHeaders else { return nil }
        return JSONFormatter.format(headers)
    }

    var formattedRequestBody: String? {
        guard let body = entry.requestBody else { return nil }
        return JSONFormatter.format(body)
    }

    var formattedResponseHeaders: String? {
        guard let headers = entry.responseHeaders else { return nil }
        return JSONFormatter.format(headers)
    }

    var formattedResponseBody: String? {
        guard let body = entry.responseBody else { return nil }
        return JSONFormatter.format(body)
    }

    var hasRequestData: Bool {
        entry.requestHeaders != nil || entry.requestBody != nil
    }

    var hasResponseData: Bool {
        entry.responseHeaders != nil || entry.responseBody != nil
    }

    var isWaitingForResponse: Bool {
        !entry.isCompleted && !hasResponseData
    }

    // MARK: - Init

    init(entry: NetworkEntry) {
        self.entry = entry
    }

    // MARK: - Actions

    func copyToClipboard(_ content: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }
}
