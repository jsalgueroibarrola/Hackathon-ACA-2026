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
        .environment(dependencies.locationViewModel)
        .environment(dependencies.favoritesViewModel)
        .environment(\.liveFeeds, dependencies.liveFeedService)
        .environment(\.schedules, dependencies.scheduleRepository)
        .environment(\.routeEstimates, dependencies.routeService)
        .environment(\.routeShapes, dependencies.routeShapes)
    }
}
