import SwiftUI

enum AppRoute: Hashable {
    case favorites
    case station(id: String)
    case journey(JourneyQuery)
}

extension View {
    func appRouteDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .favorites:
                FavoriteStationsView()
            case .station(let id):
                StationDestination(stationID: id)
            case .journey(let query):
                JourneyResultsView(query: query)
            }
        }
    }
}
