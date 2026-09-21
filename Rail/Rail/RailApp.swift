//
//  RailApp.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//

import SwiftUI
import SwiftData

@main
struct RailApp: App {
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(dependencies.modelContainer)
        .environment(dependencies.viewModel)
    }
}
