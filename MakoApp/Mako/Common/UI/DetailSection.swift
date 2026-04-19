//
//  DetailSection.swift
//  Mako
//

import SwiftUI

struct DetailSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
            content
        }
    }
}

#Preview {
    DetailSection("Sample Section") {
        Text("Content goes here")
            .font(.system(.body, design: .monospaced))
    }
    .padding()
}
