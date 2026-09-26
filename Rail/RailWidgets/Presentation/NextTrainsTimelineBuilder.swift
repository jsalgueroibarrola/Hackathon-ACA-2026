import Foundation
import WidgetKit

enum NextTrainsTimelineBuilder {
    static let grace: TimeInterval = 60
    static let minimumSpacing: TimeInterval = 300
    static let maximumEntries = 200
    static let retryInterval: TimeInterval = 3600

    static func unconfigured(now: Date) -> Timeline<NextTrainsWidgetEntry> {
        single(.unconfigured, now: now)
    }

    static func timeline(
        for snapshot: NextTrainsWidgetSnapshot,
        now: Date,
        limit: Int
    ) -> Timeline<NextTrainsWidgetEntry> {
        switch snapshot {
        case .unavailable:
            single(.dataMissing, now: now)
        case .unknownStation:
            single(.unknownStation, now: now)
        case .station(let station):
            departures(for: station, now: now, limit: limit)
        }
    }

    static func cutoffs(for departures: [Date], now: Date) -> [Date] {
        clusterEnds(of: departures.filter { $0 > now }.sorted())
            .reduce(into: [now]) { result, end in
                guard let last = result.last else { return }

                result.append(
                    max(
                        end.addingTimeInterval(grace),
                        last.addingTimeInterval(minimumSpacing)
                    )
                )
            }
    }

    private static func clusterEnds(of departures: [Date]) -> [Date] {
        departures
            .reduce(into: [(first: Date, last: Date)]()) { clusters, date in
                guard let current = clusters.last,
                    date.timeIntervalSince(current.last) <= minimumSpacing,
                    date.timeIntervalSince(current.first) <= minimumSpacing
                else {
                    clusters.append((first: date, last: date))
                    return
                }

                clusters[clusters.count - 1].last = date
            }
            .map(\.last)
    }

    private static func departures(
        for station: NextTrainsWidgetStation,
        now: Date,
        limit: Int
    ) -> Timeline<NextTrainsWidgetEntry> {
        let merged = cutoffs(for: station.today.map(\.date), now: now)
        let isTruncated = merged.count > maximumEntries
        let entries =
            merged
            .prefix(maximumEntries)
            .map { entry(at: $0, for: station, limit: limit) }

        return Timeline(
            entries: entries,
            policy: isTruncated
                ? .atEnd
                : .after(
                    max(
                        nextMidnight(after: now, in: station.timeZone),
                        entries.last?.date ?? now
                    )
                )
        )
    }

    private static func entry(
        at date: Date,
        for station: NextTrainsWidgetStation,
        limit: Int
    ) -> NextTrainsWidgetEntry {
        let rows = station.today.drop {
            $0.date.addingTimeInterval(grace) <= date
        }

        return NextTrainsWidgetEntry(
            date: date,
            timeZone: station.timeZone,
            stationID: station.id,
            content: rows.isEmpty
                ? .noService(
                    station: station.name,
                    firstTomorrow: station.firstTomorrow
                )
                : .departures(
                    station: station.name,
                    rows: Array(rows.prefix(limit))
                )
        )
    }

    private static func single(
        _ content: NextTrainsWidgetContent,
        now: Date
    ) -> Timeline<NextTrainsWidgetEntry> {
        Timeline(
            entries: [
                NextTrainsWidgetEntry(
                    date: now,
                    timeZone: .current,
                    content: content
                )
            ],
            policy: .after(now.addingTimeInterval(retryInterval))
        )
    }

    private static func nextMidnight(after date: Date, in timeZone: TimeZone)
        -> Date
    {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: date)
        ) ?? date.addingTimeInterval(retryInterval)
    }
}
