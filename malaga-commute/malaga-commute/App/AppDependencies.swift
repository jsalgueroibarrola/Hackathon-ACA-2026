//
//  AppDependencies.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import Foundation
import SwiftData

@MainActor
struct AppDependencies {

    let modelContainer: ModelContainer
    let viewModel: AppViewModel

    init() {
        let schema = Schema([
            TransitNetwork.self,
            Timetable.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        modelContainer = container
        viewModel = AppViewModel(
            syncService: SyncServiceImpl(
                api: APIServiceImpl(),
                repository: SwiftDataRepository(modelContainer: container)
            )
        )
    }
}
