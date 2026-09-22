import CoreLocation
import Foundation
import MapKit
import Synchronization

enum RouteError: Error, Sendable, Hashable {
    case unsupportedMode
    case throttled
    case unavailable

    init(_ error: any Error) {
        self = (error as? MKError)?.code == .loadingThrottled
            ? .throttled
            : .unavailable
    }

    var message: LocalizedStringResource {
        switch self {
        case .unsupportedMode:
            "Apple Maps no ofrece indicaciones paso a paso para este medio de transporte."
        case .throttled:
            "Demasiadas rutas seguidas. Inténtalo de nuevo en unos segundos."
        case .unavailable:
            "No se ha podido calcular la ruta hasta la estación."
        }
    }
}

protocol RouteService: Sendable {
    func estimates(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        modes: [TravelMode]
    ) async -> [TravelMode: TravelEstimate]

    func route(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        mode: TravelMode
    ) async throws(RouteError) -> TravelRoute
}

final class RouteServiceImpl: RouteService {

    static let shared = RouteServiceImpl()

    private struct Key: Hashable {
        let origin: LocationCell
        let destination: LocationCell
        let mode: TravelMode
    }

    private struct Entry<Value> {
        let value: Value
        let expiresAt: ContinuousClock.Instant
    }

    private let storage = Mutex<[Key: Entry<TravelEstimate>]>([:])
    private let routes = Mutex<[Key: Entry<TravelRoute>]>([:])

    @concurrent
    func estimates(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        modes: [TravelMode]
    ) async -> [TravelMode: TravelEstimate] {
        let keys = Dictionary(
            uniqueKeysWithValues: modes.map {
                (
                    $0,
                    Key(
                        origin: origin.cell,
                        destination: destination.cell,
                        mode: $0
                    )
                )
            }
        )

        let now = ContinuousClock.now
        let cached = storage.withLock { storage in
            keys.compactMapValues { key in
                storage[key].flatMap { $0.expiresAt > now ? $0.value : nil }
            }
        }

        let missing = modes.filter { cached[$0] == nil }
        guard !missing.isEmpty else { return cached }

        let fetched = await withTaskGroup(of: TravelEstimate?.self) { group in
            for mode in missing {
                group.addTask {
                    await Self.estimate(
                        mode: mode,
                        from: origin,
                        to: destination
                    )
                }
            }

            var results: [TravelMode: TravelEstimate] = [:]
            for await estimate in group {
                if let estimate { results[estimate.mode] = estimate }
            }
            return results
        }

        storage.withLock { storage in
            for (mode, estimate) in fetched {
                guard let key = keys[mode] else { continue }
                storage[key] = Entry(
                    value: estimate,
                    expiresAt: .now.advanced(by: mode.freshness)
                )
            }
        }

        return cached.merging(fetched) { _, fresh in fresh }
    }

    /// Fastest route for `mode`, cached per origin/destination cell so the
    /// small location jitter of a stationary device does not re-request
    /// directions and hit `MKError.Code.loadingThrottled`.
    @concurrent
    func route(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        mode: TravelMode
    ) async throws(RouteError) -> TravelRoute {
        guard mode.supportsDirections else { throw .unsupportedMode }

        let key = Key(
            origin: origin.cell,
            destination: destination.cell,
            mode: mode
        )
        let now = ContinuousClock.now
        let cached = routes.withLock { routes in
            routes[key].flatMap { $0.expiresAt > now ? $0.value : nil }
        }
        if let cached { return cached }

        let request = MKDirections.Request()
        request.transportType = mode.transportType
        request.requestsAlternateRoutes = true
        request.source = MKMapItem(
            location: CLLocation(
                latitude: origin.latitude,
                longitude: origin.longitude
            ),
            address: nil
        )
        request.destination = MKMapItem(
            location: CLLocation(
                latitude: destination.latitude,
                longitude: destination.longitude
            ),
            address: nil
        )

        let response: MKDirections.Response
        do {
            response = try await MKDirections(request: request).calculate()
        } catch {
            throw RouteError(error)
        }

        guard
            let fastest = response.routes.min(by: {
                $0.expectedTravelTime < $1.expectedTravelTime
            })
        else { throw .unavailable }

        let route = TravelRoute(fastest, mode: mode)
        routes.withLock { routes in
            routes[key] = Entry(
                value: route,
                expiresAt: .now.advanced(by: mode.freshness)
            )
        }
        return route
    }

    private static func estimate(
        mode: TravelMode,
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async -> TravelEstimate? {
        let request = MKDirections.Request()
        request.transportType = mode.transportType
        request.source = MKMapItem(
            location: CLLocation(
                latitude: origin.latitude,
                longitude: origin.longitude
            ),
            address: nil
        )
        request.destination = MKMapItem(
            location: CLLocation(
                latitude: destination.latitude,
                longitude: destination.longitude
            ),
            address: nil
        )

        guard
            let response = try? await MKDirections(request: request)
                .calculateETA()
        else { return nil }

        return TravelEstimate(
            mode: mode,
            travelTime: .seconds(response.expectedTravelTime),
            distance: Measurement(value: response.distance, unit: .meters),
            departure: response.expectedDepartureDate,
            arrival: response.expectedArrivalDate
        )
    }
}

#if DEBUG
    struct PreviewRouteService: RouteService {
        var values: [TravelMode: TravelEstimate] = [
            .walking: TravelEstimate(
                mode: .walking,
                travelTime: .seconds(1440),
                distance: Measurement(value: 1682, unit: .meters),
                departure: nil,
                arrival: nil
            ),
            .cycling: TravelEstimate(
                mode: .cycling,
                travelTime: .seconds(540),
                distance: Measurement(value: 2020, unit: .meters),
                departure: nil,
                arrival: nil
            ),
            .automobile: TravelEstimate(
                mode: .automobile,
                travelTime: .seconds(780),
                distance: Measurement(value: 2386, unit: .meters),
                departure: nil,
                arrival: nil
            ),
        ]

        func estimates(
            from origin: CLLocationCoordinate2D,
            to destination: CLLocationCoordinate2D,
            modes: [TravelMode]
        ) async -> [TravelMode: TravelEstimate] {
            values.filter { modes.contains($0.key) }
        }

        func route(
            from origin: CLLocationCoordinate2D,
            to destination: CLLocationCoordinate2D,
            mode: TravelMode
        ) async throws(RouteError) -> TravelRoute {
            guard mode.supportsDirections else { throw .unsupportedMode }
            guard let estimate = values[mode] else { throw .unavailable }

            return TravelRoute(
                mode: mode,
                name: "Alameda Principal",
                travelTime: estimate.travelTime,
                distance: estimate.distance,
                coordinates: Self.sampleCoordinates(
                    from: origin,
                    to: destination
                ),
                steps: Self.sampleSteps,
                advisories: [],
                hasTolls: false
            )
        }

        private static func sampleCoordinates(
            from origin: CLLocationCoordinate2D,
            to destination: CLLocationCoordinate2D
        ) -> [CLLocationCoordinate2D] {
            [
                origin,
                CLLocationCoordinate2D(
                    latitude: origin.latitude,
                    longitude: destination.longitude
                ),
                destination,
            ]
        }

        private static let sampleSteps = [
            RouteStep(
                position: 0,
                instructions: "Camina hacia el sur por Alameda Principal",
                notice: nil,
                distance: Measurement(value: 420, unit: .meters),
                isArrival: false
            ),
            RouteStep(
                position: 1,
                instructions: "Gira a la derecha en Avenida de Andalucía",
                notice: nil,
                distance: Measurement(value: 860, unit: .meters),
                isArrival: false
            ),
            RouteStep(
                position: 2,
                instructions: "Cruza el paso de peatones y continúa recto",
                notice: "Zona peatonal",
                distance: Measurement(value: 240, unit: .meters),
                isArrival: false
            ),
            RouteStep(
                position: 3,
                instructions: "Has llegado a tu destino",
                notice: nil,
                distance: Measurement(value: 0, unit: .meters),
                isArrival: true
            ),
        ]
    }
#endif
