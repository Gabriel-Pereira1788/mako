//
//  NetworkRowView.swift
//  Mako
//

import SwiftUI

struct NetworkRowView: View {
    let entry: NetworkEntry

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            methodLabel
            statusBadge
            urlLabel
            durationLabel
            timestampLabel
        }
        .padding(.vertical, 4)
    }

    // MARK: - Subviews

    private var methodLabel: some View {
        Text(entry.method.uppercased())
            .font(.caption)
            .bold()
            .foregroundStyle(HTTPMethod.color(for: entry.method))
            .frame(width: 50, alignment: .leading)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if let statusCode = entry.statusCode {
            let color = HTTPStatusCode.color(for: statusCode)
            Text("\(statusCode)")
                .font(.caption)
                .bold()
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.2))
                .foregroundStyle(color)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            ProgressView()
                .scaleEffect(0.5)
                .frame(width: 30)
        }
    }

    private var urlLabel: some View {
        Text(entry.url)
            .font(.system(.body, design: .monospaced))
            .lineLimit(1)
            .truncationMode(.middle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var durationLabel: some View {
        if let duration = entry.duration {
            Text("\(duration, format: .number.precision(.fractionLength(0)))ms")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private var timestampLabel: some View {
        Text(Self.timeFormatter.string(from: entry.timestamp))
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
    }
}
