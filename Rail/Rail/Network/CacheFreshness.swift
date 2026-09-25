import Foundation

struct CacheFreshness: Sendable, Equatable {
    var freshFor: Duration?
    var isStale: Bool = false

    static let unknown = CacheFreshness(freshFor: nil)
}

extension HTTPURLResponse {
    var cacheFreshness: CacheFreshness {
        CacheFreshness(
            freshFor: maxAge.map { .seconds($0 - (age ?? 0)) },
            isStale: value(forHTTPHeaderField: "Warning")?.hasPrefix("110") ?? false
        )
    }

    var retryAfter: Duration? {
        value(forHTTPHeaderField: "Retry-After")
            .flatMap { TimeInterval($0.trimmingCharacters(in: .whitespaces)) }
            .map { .seconds($0) }
    }

    private var maxAge: TimeInterval? {
        value(forHTTPHeaderField: "Cache-Control")?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { $0.hasPrefix("max-age=") }
            .flatMap { TimeInterval($0.dropFirst("max-age=".count)) }
    }

    private var age: TimeInterval? {
        value(forHTTPHeaderField: "Age")
            .flatMap { TimeInterval($0.trimmingCharacters(in: .whitespaces)) }
    }
}

extension CacheFreshness {
    func expiry(from date: Date, fallback: Duration) -> Date {
        date.addingTimeInterval(TimeInterval((freshFor ?? fallback) / .seconds(1)))
    }
}
