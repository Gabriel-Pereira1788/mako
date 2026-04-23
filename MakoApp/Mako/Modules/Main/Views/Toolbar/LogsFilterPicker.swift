//
//  LogsFilterPicker.swift
//  Mako
//
//  Filter controls for JS Logs tab
//

import SwiftUI

struct LogsFilterPicker: View {
    @Bindable var context: FilterContext

    var body: some View {
        HStack(spacing: 8) {
            levelPicker
            sourcePicker
        }
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

    private var sourcePicker: some View {
        Picker("Source", selection: Binding(
            get: { context.selectedSource },
            set: { context.selectedSource = $0 }
        )) {
            Text("All Sources").tag(nil as LogSource?)
            Divider()
            ForEach(LogSource.allCases, id: \.self) { source in
                Text(source.displayName).tag(source as LogSource?)
            }
        }
        .frame(width: 130)
    }
}
