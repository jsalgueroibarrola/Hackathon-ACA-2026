import SwiftUI

struct OnboardingWidgetSample: Equatable {
    struct Row: Identifiable, Equatable {
        let id: String
        let color: Color
        let destination: String
        let minutesAway: Int
    }

    let station: String
    let rows: [Row]

    static let placeholder = OnboardingWidgetSample(
        station: "Málaga-Centro Alameda",
        rows: [
            Row(id: "C1", color: .fillTertiary, destination: "Fuengirola", minutesAway: 4),
            Row(id: "C2", color: .fillTertiary, destination: "Álora", minutesAway: 11),
        ]
    )
}

enum OnboardingWidgetSampleBuilder {
    static let rowLimit = 2
    static let firstDepartureMinutes = 4
    static let minutesBetweenDepartures = 7

    static func sample(lines: [Line]) -> OnboardingWidgetSample? {
        let lines = lines.sortedByID
        guard let station = lines.lazy.flatMap({ $0.orderedStops.compactMap(\.station) }).first else {
            return nil
        }
        let rows = lines
            .filter { line in line.orderedStops.contains { $0.station?.id == station.id } }
            .compactMap { line in destination(of: line, from: station).map { (line, $0) } }
            .prefix(rowLimit)
            .enumerated()
            .map { index, pair in
                OnboardingWidgetSample.Row(
                    id: pair.0.id,
                    color: pair.0.tint.base,
                    destination: pair.1,
                    minutesAway: firstDepartureMinutes + index * minutesBetweenDepartures
                )
            }
        return rows.isEmpty ? nil : OnboardingWidgetSample(station: station.name, rows: rows)
    }

    private static func destination(of line: Line, from station: Station) -> String? {
        let stops = line.orderedStops.compactMap(\.station)
        return stops.last?.id == station.id ? stops.first?.name : stops.last?.name
    }
}
