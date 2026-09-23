import CoreLocation
import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class LocationViewModel {

    private(set) var authorization: LocationAuthorization
    private(set) var location: UserLocation?
    private(set) var isLocationUnavailable = false
    private(set) var retryAttempt = 0

    private let service: any LocationService
    private let repository: any UserStationsRepository

    init(
        service: any LocationService,
        repository: any UserStationsRepository
    ) {
        self.service = service
        self.repository = repository
        self.authorization = service.authorization
    }

    var isTracking: Bool { authorization == .authorized }

    var canRequestAccess: Bool { authorization == .notDetermined }

    var isAccessBlocked: Bool { authorization.isBlocked }

    var isLocating: Bool { isTracking && location == nil }

    var hasLocationFailed: Bool {
        isTracking && location == nil && isLocationUnavailable
    }

    func requestAccess() {
        service.requestAuthorization()
    }

    func retry() {
        isLocationUnavailable = false
        retryAttempt += 1
    }

    func saveLocation(_ location: SavedLocation) {
        attempt { try repository.saveStation(location) }
    }

    func clearSavedLocation() {
        attempt { try repository.clearSavedStation() }
    }

    func observe() async {
        for await event in service.events() {
            switch event {
            case .authorization(let value):
                authorization = value
                location = value == .authorized ? location : nil
            case .reading(let reading):
                location = reading
                isLocationUnavailable = false
            case .unavailable:
                isLocationUnavailable = true
            }
        }
    }

    func distance(to coordinate: CLLocationCoordinate2D) -> Measurement<UnitLength>? {
        location?.distance(to: coordinate)
    }

    func nearest(_ stations: [Station], limit: Int = 3) -> [NearbyStation] {
        location.map {
            NearbyStation.closest(to: $0, among: stations, limit: limit)
        } ?? []
    }

    private func attempt(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            Logger.userStations.error(
                "Saved station update failed: \(String(describing: error), privacy: .public)"
            )
        }
    }
}

#if DEBUG
@MainActor
private struct PreviewLocationService: LocationService {
    let authorization: LocationAuthorization

    func requestAuthorization() {}

    func events() -> AsyncStream<LocationEvent> {
        AsyncStream { $0.yield(.authorization(authorization)) }
    }
}

extension UserLocation {
    static let alameda = UserLocation(
        latitude: 36.7185,
        longitude: -4.4285,
        horizontalAccuracy: 12,
        timestamp: .distantPast
    )
}

extension LocationViewModel {
    static func preview(
        authorization: LocationAuthorization = .authorized,
        location: UserLocation? = .alameda,
        isLocationUnavailable: Bool = false,
        repository: any UserStationsRepository = PreviewUserStationsRepository()
    ) -> LocationViewModel {
        let model = LocationViewModel(
            service: PreviewLocationService(authorization: authorization),
            repository: repository
        )
        model.location = authorization == .authorized ? location : nil
        model.isLocationUnavailable = isLocationUnavailable
        return model
    }
}
#endif
