//
//  AppDependencies.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import Foundation
import SwiftData

@MainActor
struct AppDependencies {

    let modelContainer: ModelContainer
    let viewModel: AppViewModel
    let locationViewModel: LocationViewModel
    let favoritesViewModel: FavoritesViewModel

    init() {
        let configuration = RailStore.configuration()

        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: RailStore.schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        let transit = SwiftDataTransitRepository(modelContainer: container)
        let userStations = SwiftDataUserStationsRepository(
            modelContainer: container
        )

        modelContainer = container
        viewModel = AppViewModel(
            syncService: SyncServiceImpl(
                api: APIServiceImpl(),
                repository: transit
            )
        )
        locationViewModel = LocationViewModel(
            service: LocationServiceImpl(),
            repository: userStations
        )
        favoritesViewModel = FavoritesViewModel(repository: userStations)
    }
}
