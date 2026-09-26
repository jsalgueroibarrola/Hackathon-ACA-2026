import Foundation
import SwiftData

@MainActor
struct AppDependencies {

    let modelContainer: ModelContainer
    let viewModel: AppViewModel
    let locationViewModel: LocationViewModel
    let favoritesViewModel: FavoritesViewModel
    let liveFeedService: any LiveFeedService
    let scheduleRepository: any ScheduleRepository
    let routeService: any RouteService
    let routeShapes: RouteShapeCache

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

        let api = APIServiceImpl()

        modelContainer = container
        viewModel = AppViewModel(
            syncService: SyncServiceImpl(
                api: api,
                repository: transit
            )
        )
        locationViewModel = LocationViewModel(
            service: LocationServiceImpl(),
            repository: userStations
        )
        favoritesViewModel = FavoritesViewModel(repository: userStations)
        liveFeedService = LiveFeedServiceImpl(
            api: api,
            repository: SwiftDataLiveFeedRepository(modelContainer: container)
        )
        scheduleRepository = SwiftDataScheduleRepository(modelContainer: container)
        routeService = RouteServiceImpl()
        routeShapes = RouteShapeCache()
    }
}
