import Foundation

extension Calendar {
    static func network(in timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    func serviceDay(from value: String) -> Date? {
        let parts = value.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return date(
            from: DateComponents(year: parts[0], month: parts[1], day: parts[2])
        )
    }
}

extension TimeZone {
    init(networkIdentifier identifier: String?) {
        self = identifier.flatMap(TimeZone.init(identifier:)) ?? .gmt
    }
}
