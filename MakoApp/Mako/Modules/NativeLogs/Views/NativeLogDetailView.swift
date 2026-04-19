//
//  NativeLogDetailView.swift
//  Mako
//

import SwiftUI

struct NativeLogDetailView: View {
    let log: LogEntry
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    messageSection
                    if log.metadata != nil {
                        metadataSection
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 400 ,maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: log.logLevel.icon)
                    .foregroundStyle(log.logLevel.color)
                    .font(.headline)

                Text(log.logLevel.rawValue.uppercased())
                    .font(.headline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(log.logLevel.color.opacity(0.2))
                    .foregroundStyle(log.logLevel.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text(log.logSource.displayName)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(log.logSource.color.opacity(0.2))
                    .foregroundStyle(log.logSource.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()

                Text(log.timestamp, format: .dateTime.day().month().year().hour().minute().second())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Close detail view")
            }
        }
        .padding()
    }

    private var messageSection: some View {
        DetailSection("Message") {
            Text(log.message)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    @ViewBuilder
    private var metadataSection: some View {
        if let metadata = log.metadata {
            DetailSection("Metadata") {
                Text(JSONFormatter.format(metadata))
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    NativeLogDetailView(
        log: LogEntry(
            level: .warn,
            source: .ios,
            logType: .native,
            message: "Native iOS warning: Memory pressure detected in the application.",
            metadata: "{\"memoryUsage\": \"85%\", \"availableMemory\": \"256MB\"}"
        ),
        onClose: {}
    )
}
