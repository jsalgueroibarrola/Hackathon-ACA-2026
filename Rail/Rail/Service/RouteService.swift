import CoreLocation
import Foundation
import MapKit
import Synchronization

protocol RouteService: Sendable {
    func estimates(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        modes: [TravelMode]
    ) async -> [TravelMode: TravelEstimate]
}

struct DisabledRouteService: RouteService {
    func estimates(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        modes: [TravelMode]
    ) async -> [TravelMode: TravelEstimate] {
        [:]
    }
}

final class RouteServiceImpl: RouteService {

    private struct Key: Hashable {
        let origin: LocationCell
        let destination: LocationCell
        let mode: TravelMode
    }

    private struct Entry {
        let value: TravelEstimate
        let expiresAt: ContinuousClock.Instant
    }

    private let storage = Mutex<[Key: Entry]>([:])

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
    }
#endif
