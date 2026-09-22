import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class LocationViewModel {

    private(set) var authorization: LocationAuthorization
    private(set) var location: UserLocation?

    private let service: any LocationService

    init(service: any LocationService) {
        self.service = service
        self.authorization = service.authorization
    }

    var isTracking: Bool { authorization == .authorized }

    var canRequestAccess: Bool { authorization == .notDetermined }

    var isAccessBlocked: Bool { authorization.isBlocked }

    var isLocating: Bool { isTracking && location == nil }

    func requestAccess() {
        service.requestAuthorization()
    }

    func observe() async {
        for await event in service.events() {
            switch event {
            case .authorization(let value):
                authorization = value
                location = value == .authorized ? location : nil
            case .reading(let reading):
                location = reading
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
        location: UserLocation? = .alameda
    ) -> LocationViewModel {
        let model = LocationViewModel(
            service: PreviewLocationService(authorization: authorization)
        )
        model.location = authorization == .authorized ? location : nil
        return model
    }
}
#endif
