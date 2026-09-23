import CoreLocation

@MainActor
protocol LocationService {
    var authorization: LocationAuthorization { get }
    func requestAuthorization()
    func events() -> AsyncStream<LocationEvent>
}

@MainActor
final class LocationServiceImpl: LocationService {

    private let manager = CLLocationManager()
    private var session: CLServiceSession?
    private var continuation: AsyncStream<LocationEvent>.Continuation?
    private var updates: Task<Void, any Error>?
    private var generation = 0

    var authorization: LocationAuthorization {
        LocationAuthorization(manager.authorizationStatus)
    }

    private var hasOptedIn: Bool {
        session != nil || authorization != .notDetermined
    }

    func requestAuthorization() {
        guard authorization == .notDetermined else { return }
        startUpdates()
    }

    func events() -> AsyncStream<LocationEvent> {
        stop(token: generation)
        generation += 1

        let token = generation
        let (stream, continuation) = AsyncStream<LocationEvent>.makeStream()
        self.continuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.stop(token: token) }
        }
        continuation.yield(.authorization(authorization))
        if hasOptedIn {
            startUpdates()
        }
        return stream
    }

    private func stop(token: Int) {
        guard token == generation else { return }
        updates?.cancel()
        updates = nil
        continuation?.finish()
        continuation = nil
    }

    private func startUpdates() {
        session = session ?? CLServiceSession(authorization: .whenInUse)
        guard updates == nil, let continuation else { return }

        if authorization == .authorized, let cached = manager.location {
            continuation.yield(.reading(UserLocation(cached)))
        }

        updates = Task {
            defer { continuation.finish() }
            var reported = authorization
            var isAvailable = true
            for try await update in CLLocationUpdate.liveUpdates() {
                let current = update.authorization ?? authorization
                if current != reported {
                    reported = current
                    continuation.yield(.authorization(current))
                }
                if update.locationUnavailable, isAvailable {
                    isAvailable = false
                    continuation.yield(.unavailable)
                }
                if let location = update.location {
                    isAvailable = true
                    continuation.yield(.reading(UserLocation(location)))
                }
            }
        }
    }
}

private extension CLLocationUpdate {
    var authorization: LocationAuthorization? {
        if location != nil {
            .authorized
        } else if authorizationDenied || authorizationDeniedGlobally {
            .denied
        } else if authorizationRestricted {
            .restricted
        } else {
            nil
        }
    }
}
