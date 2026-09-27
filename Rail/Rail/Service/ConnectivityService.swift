import Network

protocol ConnectivityService: Sendable {
    func updates() -> AsyncStream<Bool>
}

struct NetworkConnectivityService: ConnectivityService {
    func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let monitoring = Task {
                for await path in NWPathMonitor() {
                    continuation.yield(path.status == .satisfied)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in monitoring.cancel() }
        }
    }
}

struct DisabledConnectivityService: ConnectivityService {
    func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(true)
            continuation.finish()
        }
    }
}

#if DEBUG
struct PreviewConnectivityService: ConnectivityService {
    var isOnline = true

    func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(isOnline)
            continuation.finish()
        }
    }
}
#endif
