import Foundation

enum RailWidgetLink {
    static let nextTrainsKind = "com.JadeHorizonStudio.Rail.next-trains"

    private static let scheme = "rail"
    private static let stationHost = "station"

    static func station(id: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = stationHost
        components.path = "/\(id)"
        return components.url
    }

    static func stationID(from url: URL) -> String? {
        guard url.scheme == scheme, url.host == stationHost else { return nil }

        let id = url.path.trimmingPrefix("/")
        return id.isEmpty ? nil : String(id)
    }
}
