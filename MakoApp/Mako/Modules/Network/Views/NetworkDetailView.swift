//
//  NetworkDetailView.swift
//  Mako
//

import SwiftUI

struct NetworkDetailView: View {
    @Bindable var viewModel: NetworkDetailViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            Picker("", selection: $viewModel.selectedTab) {
                Text("Request").tag(NetworkDetailTab.request)
                Text("Response").tag(NetworkDetailTab.response)
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.selectedTab == .request {
                        requestContent
                    } else {
                        responseContent
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        .task(id: viewModel.entry.id) {
            await viewModel.loadFormattedBodies()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.methodDisplay)
                    .font(.headline)
                    .bold()

                if let statusCode = viewModel.statusCode {
                    let color = HTTPStatusCode.color(for: statusCode)
                    Text("\(statusCode)")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.2))
                        .foregroundStyle(color)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Spacer()

                if let duration = viewModel.durationDisplay {
                    Text(duration)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                closeButton
            }

            Text(viewModel.entry.url)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .padding()
    }

    private var closeButton: some View {
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

    // MARK: - Request Content

    private var requestContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let headers = viewModel.formattedRequestHeaders {
                sectionWithCopy(title: "Headers", content: headers)
            }

            if viewModel.isLoadingBody && viewModel.entry.requestBody != nil {
                bodyLoadingView
            } else if let body = viewModel.formattedRequestBodyAsync {
                bodySectionWithCopy(title: "Body", content: body)
            }

            if !viewModel.hasRequestData {
                Text("No request data")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Response Content

    private var responseContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let headers = viewModel.formattedResponseHeaders {
                sectionWithCopy(title: "Headers", content: headers)
            }

            if viewModel.isLoadingBody && viewModel.entry.responseBody != nil {
                bodyLoadingView
            } else if let body = viewModel.formattedResponseBodyAsync {
                bodySectionWithCopy(title: "Body", content: body)
            }

            if !viewModel.hasResponseData {
                if viewModel.isWaitingForResponse {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Waiting for response...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No response data")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var bodyLoadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Formatting...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }

    // MARK: - Reusable Components

    private func sectionWithCopy(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    viewModel.copyToClipboard(content)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
            }

            codeBlock(content)
        }
    }

    private func codeBlock(_ content: String) -> some View {
        Text(content)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func bodySectionWithCopy(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    viewModel.copyToClipboard(content)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
            }

            LargeTextView(text: content)
                .frame(minHeight: 300, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
