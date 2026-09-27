import SwiftUI

extension EnvironmentValues {
    @Entry var routeEstimates: any RouteService = DisabledRouteService()
}

extension View {
    func loadRouteEstimates(
        _ request: RouteEstimateRequest?,
        into estimates: Binding<RouteEstimates?>
    ) -> some View {
        modifier(RouteEstimateLoader(request: request, estimates: estimates))
    }
}

private struct RouteEstimateLoader: ViewModifier {
    let request: RouteEstimateRequest?
    @Binding var estimates: RouteEstimates?

    @Environment(\.routeEstimates) private var routeEstimates

    func body(content: Content) -> some View {
        content.task(id: request?.id) {
            guard let request else { return }
            let values = await routeEstimates.estimates(
                from: request.origin,
                to: request.destination,
                modes: request.id.modes
            )
            guard !Task.isCancelled else { return }
            estimates = RouteEstimates(requestID: request.id, values: values)
        }
    }
}
