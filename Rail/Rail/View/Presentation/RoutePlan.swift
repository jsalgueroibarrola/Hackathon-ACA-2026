import Foundation

enum RoutePlan: Sendable {
    case locating
    case calculating
    case directions(TravelRoute)
    case estimate(TravelEstimate)
    case failure(RouteError)

    var route: TravelRoute? {
        if case .directions(let route) = self { route } else { nil }
    }
}
