import SwiftUI

extension EnvironmentValues {
    @Entry var routeEstimates: any RouteService = DisabledRouteService()
}
