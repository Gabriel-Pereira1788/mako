//
//  SyntaxHighlightedJSONView.swift
//  Mako
//

import SwiftUI

struct SyntaxHighlightedJSONView: View {
    let json: String

    @State private var copied = false
    @State private var processedLines: [ProcessedLine] = []
    @State private var formattedJSONCache: String = ""

    private var lineNumberWidth: CGFloat {
        let digitCount = max(1, String(processedLines.count).count)
        return CGFloat(digitCount * 10 + 16)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if processedLines.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(processedLines) { line in
                        JSONLineRow(
                            lineNumber: line.number,
                            content: line.highlighted,
                            lineNumberWidth: lineNumberWidth
                        )
                    }
                }
                .textSelection(.enabled)
                .padding(.vertical, 12)
            }

            copyButton
        }
        .font(.system(.caption, design: .monospaced))
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task(id: json) {
            await processJSON()
        }
    }

    private func processJSON() async {
        let formatted = JSONFormatter.format(json)
        formattedJSONCache = formatted

        let lines = formatted.components(separatedBy: "\n")
        var result: [ProcessedLine] = []
        result.reserveCapacity(lines.count)

        for (index, line) in lines.enumerated() {
            result.append(ProcessedLine(
                id: index,
                number: index + 1,
                highlighted: JSONSyntaxHighlighter.highlight(line)
            ))
        }

        await MainActor.run {
            processedLines = result
        }
    }

    private var copyButton: some View {
        Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(formattedJSONCache.isEmpty ? json : formattedJSONCache, forType: .string)
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(copied ? .green : .secondary)
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .padding(8)
        .help("Copy JSON")
    }
}

private struct ProcessedLine: Identifiable {
    let id: Int
    let number: Int
    let highlighted: AttributedString
}

private struct JSONLineRow: View {
    let lineNumber: Int
    let content: AttributedString
    let lineNumberWidth: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("\(lineNumber)")
                .foregroundStyle(.secondary.opacity(0.6))
                .frame(width: lineNumberWidth, alignment: .trailing)
                .padding(.trailing, 8)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.5))

            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
        }
        .frame(height: 16)
    }
}

#Preview {
    SyntaxHighlightedJSONView(
        json: """
        {"args": {}, "headers": {"Accept": "*/*", "Host": "httpbin.org", "Priority": "u=3"}, "origin": "177.37.183.24", "url": "https://httpbin.org/get"}
        """
    )
    .frame(width: 500, height: 400)
    .padding()
}
