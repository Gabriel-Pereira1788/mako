//
//  LogRowView.swift
//  Mako
//

import SwiftUI

struct LogRowView: View {
    let entry: LogEntry

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Level icon
            Image(systemName: entry.logLevel.icon)
                .foregroundStyle(entry.logLevel.color)
                .frame(width: 16)

            // Source badge
            Text(entry.logSource.displayName)
                .font(.caption2)
                .bold()
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(entry.logSource.color.opacity(0.2))
                .foregroundStyle(entry.logSource.color)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            // Message
            Text(entry.message)
                .font(.system(.body, design: .monospaced))
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Timestamp
            Text(Self.timeFormatter.string(from: entry.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}
