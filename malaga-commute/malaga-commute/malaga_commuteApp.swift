//
//  malaga_commuteApp.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import SwiftUI
import SwiftData

@main
struct malaga_commuteApp: App {
    var sharedModelContainer: ModelContainer = {
        // The two payload roots. SwiftData pulls in the rest of the graph from them:
        // Line, Station and LineStop through TransitNetwork, and Trip through Timetable.
        let schema = Schema([
            TransitNetwork.self,
            Timetable.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
