//
//  AppCommands.swift
//  Mako
//
//  Menu bar commands for the app
//

import SwiftUI

// MARK: - Focused Values

struct AppCommandsKey: FocusedValueKey {
    typealias Value = AppCommandActions
}

extension FocusedValues {
    var appCommands: AppCommandActions? {
        get { self[AppCommandsKey.self] }
        set { self[AppCommandsKey.self] = newValue }
    }
}

// MARK: - Command Actions

@MainActor
struct AppCommandActions {
    var toggleInspector: () -> Void
    var clearLogs: () -> Void
    var clearAllLogs: () -> Void

    var openJSLogs: () -> Void
    var openNetwork: () -> Void
    var openNativeLogs: () -> Void

    var splitHorizontal: () -> Void
    var splitVertical: () -> Void
    var closePanel: () -> Void
    var closeTab: () -> Void

    var canSplit: Bool
    var hasActiveTab: Bool
    var hasMultiplePanels: Bool
    var hasSelectedDevice: Bool
}

// MARK: - App Commands

struct AppMenuCommands: Commands {
    @FocusedValue(\.appCommands) var commands

    var body: some Commands {
        // Replace New Item in File menu
        CommandGroup(replacing: .newItem) {
            Button("New Panel") {
                commands?.splitHorizontal()
            }
            .keyboardShortcut("N", modifiers: [.command, .shift])
            .disabled(!(commands?.canSplit ?? false))
        }

        // View Menu additions
        CommandGroup(after: .toolbar) {
            Button(commands != nil ? "Toggle Inspector" : "Toggle Inspector") {
                commands?.toggleInspector()
            }
            .keyboardShortcut("I", modifiers: [.command, .option])

            Divider()

            Button("Show JS Logs") {
                commands?.openJSLogs()
            }
            .keyboardShortcut("1", modifiers: .command)
            .disabled(!(commands?.hasSelectedDevice ?? false))

            Button("Show Network") {
                commands?.openNetwork()
            }
            .keyboardShortcut("2", modifiers: .command)
            .disabled(!(commands?.hasSelectedDevice ?? false))

            Button("Show Native Logs") {
                commands?.openNativeLogs()
            }
            .keyboardShortcut("3", modifiers: .command)
            .disabled(!(commands?.hasSelectedDevice ?? false))
        }

        // Custom Panel Menu
        CommandMenu("Panel") {
            Button("Split Horizontal") {
                commands?.splitHorizontal()
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(!(commands?.canSplit ?? false))

            Button("Split Vertical") {
                commands?.splitVertical()
            }
            .keyboardShortcut("D", modifiers: [.command, .option])
            .disabled(!(commands?.canSplit ?? false))

            Divider()

            Button("Close Tab") {
                commands?.closeTab()
            }
            .keyboardShortcut("W", modifiers: .command)
            .disabled(!(commands?.hasActiveTab ?? false))

            Button("Close Panel") {
                commands?.closePanel()
            }
            .keyboardShortcut("W", modifiers: [.command, .shift])
            .disabled(!(commands?.hasMultiplePanels ?? false))
        }

        // Logs Menu
        CommandMenu("Logs") {
            Button("Clear Current Logs") {
                commands?.clearLogs()
            }
            .keyboardShortcut("K", modifiers: .command)
            .disabled(!(commands?.hasSelectedDevice ?? false))

            Button("Clear All Logs") {
                commands?.clearAllLogs()
            }
            .keyboardShortcut("K", modifiers: [.command, .shift])
        }
    }
}
