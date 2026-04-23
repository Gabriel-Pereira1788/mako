//
//  NativeLogsFilterPicker.swift
//  Mako
//
//  Filter controls for Native Logs tab
//

import SwiftUI

struct NativeLogsFilterPicker: View {
    @Bindable var context: FilterContext
    var platform: DevicePlatform = .unknown

    var body: some View {
        HStack(spacing: 8) {
            if platform != .unknown {
                platformBadge
            }
            levelPicker
        }
    }

    private var platformBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: platform.iconName)
            Text(platform.displayName)
        }
        .font(.caption)
        .bold()
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(platform.color.opacity(0.2))
        .foregroundStyle(platform.color)
        .clipShape(.rect(cornerRadius: 6))
    }

    private var levelPicker: some View {
        Picker("Level", selection: Binding(
            get: { context.selectedLevel },
            set: { context.selectedLevel = $0 }
        )) {
            Text("All Levels").tag(nil as LogLevel?)
            Divider()
            ForEach(LogLevel.allCases, id: \.self) { level in
                Label(level.rawValue.capitalized, systemImage: level.icon)
                    .tag(level as LogLevel?)
            }
        }
        .frame(width: 130)
    }
}
