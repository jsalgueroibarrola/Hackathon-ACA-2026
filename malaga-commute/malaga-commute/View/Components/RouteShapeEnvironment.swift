//
//  RouteShapeEnvironment.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI

extension EnvironmentValues {
    /// Default is `RouteShapeCache.shared` rather than a fresh instance: an
    /// `@Entry` default that allocates is re-evaluated on every environment
    /// read, which invalidates every reader on unrelated environment writes.
    @Entry var routeShapes: RouteShapeCache = .shared
}
