import SwiftUI

extension EnvironmentValues {
    /// Default is `RouteServiceImpl.shared` rather than a fresh instance: an
    /// `@Entry` default that allocates is re-evaluated on every environment
    /// read, which would also throw away the estimate cache on every read.
    @Entry var routeEstimates: any RouteService = RouteServiceImpl.shared
}
