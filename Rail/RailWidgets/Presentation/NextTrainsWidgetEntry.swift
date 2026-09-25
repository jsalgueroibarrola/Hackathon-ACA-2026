import Foundation
import WidgetKit

struct NextTrainsWidgetEntry: TimelineEntry {
    let date: Date
    let timeZone: TimeZone
    let stationID: String?
    let content: NextTrainsWidgetContent

    init(
        date: Date,
        timeZone: TimeZone,
        stationID: String? = nil,
        content: NextTrainsWidgetContent
    ) {
        self.date = date
        self.timeZone = timeZone
        self.stationID = stationID
        self.content = content
    }

    var deepLink: URL? {
        stationID.flatMap(RailWidgetLink.station(id:))
    }
}

enum NextTrainsWidgetContent: Hashable, Sendable {
    case unconfigured
    case dataMissing
    case unknownStation
    case noService(station: String, firstTomorrow: Date?)
    case departures(station: String, rows: [NextTrainsWidgetRow])
}

struct NextTrainsWidgetRow: Identifiable, Hashable, Sendable {
    let id: String
    let line: String
    let colorHex: String
    let destination: String
    let date: Date
}

extension NextTrainsWidgetEntry {
    static func sample(at date: Date, limit: Int = 3) -> NextTrainsWidgetEntry {
        let lines = [
            (line: "C-1", color: "DA291C", destination: "Fuengirola"),
            (line: "C-2", color: "0057A8", destination: "Álora"),
        ]
        let rows = (0..<max(1, limit)).map { index in
            let sample = lines[index % lines.count]

            return NextTrainsWidgetRow(
                id: "sample-\(index)",
                line: sample.line,
                colorHex: sample.color,
                destination: sample.destination,
                date: date.addingTimeInterval(TimeInterval(4 + index * 7) * 60)
            )
        }

        return NextTrainsWidgetEntry(
            date: date,
            timeZone: .current,
            stationID: "54413",
            content: .departures(
                station: "Málaga Centro Alameda",
                rows: rows
            )
        )
    }
}
