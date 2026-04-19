//
//  MakoApp.swift
//  Mako
//
//  Created by Gabriel Pereira on 09/04/26.
//

import SwiftUI
import SwiftData

@main
struct MakoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Device.self,
            LogEntry.self,
            NetworkEntry.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 700)
    }
}
