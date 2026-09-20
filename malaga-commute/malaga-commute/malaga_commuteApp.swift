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
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(dependencies.modelContainer)
        .environment(dependencies.viewModel)
    }
}
