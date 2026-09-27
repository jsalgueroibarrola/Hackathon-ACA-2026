import Foundation

enum NearbyDepartures: Hashable, Sendable {
    case loading
    case upcoming([NearbyDeparture])
    case finished(firstTomorrow: String?)
}

struct NearbyDeparture: Identifiable, Hashable, Sendable {
    let id: String
    let lineID: String
    let colorHex: String
    let destination: String
    let wait: NearbyDepartureWait
    let delayMinutes: Int?
}

enum NearbyDepartureWait: Hashable, Sendable {
    case now
    case minutes(Int)
    case time(String)
}

struct NearbyLiveTrain: Hashable, Sendable {
    let delaySeconds: Int
    let passedStationIDs: Set<String>
    let sampledAt: Date

    func isCurrent(at date: Date) -> Bool {
        date.timeIntervalSince(sampledAt) <= TrainTrack.maximumAge
    }
}

enum NearbyDeparturesBuilder {
    static let visibleDestinations = 2

    static func departures(
        from schedules: NextTrainsSchedules,
        liveTrains: [String: NearbyLiveTrain],
        now: Date,
        limit: Int = visibleDestinations
    ) -> NearbyDepartures {
        let format = Date.FormatStyle.departureTime(in: schedules.timeZone)
        let candidates = schedules.today.compactMap { line in
            line.departures.lazy
                .compactMap { departure -> (line: StationLineSchedule, delay: Int, date: Date)? in
                    let live = liveTrains[liveKey(lineID: line.lineID, train: departure.train)]
                        .flatMap { $0.isCurrent(at: now) ? $0 : nil }
                    guard live?.passedStationIDs.contains(schedules.stationID) != true else { return nil }
                    let delay = live?.delaySeconds ?? 0
                    return (
                        line: line,
                        delay: delay,
                        date: departure.date.addingTimeInterval(TimeInterval(delay))
                    )
                }
                .first { $0.date >= now }
        }
        let rows = Dictionary(grouping: candidates, by: \.line.destination)
            .values
            .compactMap { $0.min { ($0.date, $0.line.lineID) < ($1.date, $1.line.lineID) } }
            .sorted { ($0.date, $0.line.lineID) < ($1.date, $1.line.lineID) }
            .prefix(limit)
            .map {
                NearbyDeparture(
                    id: $0.line.id,
                    lineID: $0.line.lineID,
                    colorHex: $0.line.colorHex,
                    destination: $0.line.destination,
                    wait: wait(until: $0.date, from: now, format: format),
                    delayMinutes: $0.delay / 60 > 0 ? $0.delay / 60 : nil
                )
            }

        return rows.isEmpty
            ? .finished(
                firstTomorrow: schedules.tomorrow
                    .flatMap(\.departures)
                    .map(\.date)
                    .min()
                    .map { $0.formatted(format) }
            )
            : .upcoming(Array(rows))
    }

    static func liveTrains(
        from trains: [LiveTrain],
        lines: [Line],
        fetchedAt: Date?
    ) -> [String: NearbyLiveTrain] {
        let linesByID = Dictionary(
            lines.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return Dictionary(
            trains.compactMap { train in
                (train.sampledAt ?? fetchedAt).map { sampledAt in
                    (
                        liveKey(lineID: train.lineID, train: train.train),
                        NearbyLiveTrain(
                            delaySeconds: max(0, train.delaySeconds ?? 0),
                            passedStationIDs: linesByID[train.lineID]
                                .map { passedStationIDs(of: train, on: $0) } ?? [],
                            sampledAt: sampledAt
                        )
                    )
                }
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    private static func passedStationIDs(of train: LiveTrain, on line: Line) -> Set<String> {
        let sequences = Dictionary(
            line.orderedStops.map { ($0.stationID, $0.sequence) },
            uniquingKeysWith: { first, _ in first }
        )
        guard let direction = train.direction
            ?? TrainTrackBuilder.direction(
                from: train.stopID.flatMap { sequences[$0] },
                to: train.nextStopID.flatMap { sequences[$0] }
            )
        else { return [] }
        let order = line.orderedStops(for: direction).map(\.stationID)
        let stop = train.stopID.flatMap(order.firstIndex(of:))
        let next = train.nextStopID.flatMap(order.firstIndex(of:))
        let boundary: Int? = switch train.status {
        case .at: stop ?? next
        case .left: next ?? stop.map { $0 + 1 }
        case .approaching, .unknown: next ?? stop
        }
        return boundary.map { Set(order.prefix($0)) } ?? []
    }

    private static func liveKey(lineID: String, train: String) -> String {
        "\(lineID)-\(train)"
    }

    private static func wait(
        until date: Date,
        from now: Date,
        format: Date.FormatStyle
    ) -> NearbyDepartureWait {
        switch Int(date.timeIntervalSince(now) / 60) {
        case 0: .now
        case let minutes where minutes < StationTimetableBuilder.countdownLimit: .minutes(minutes)
        default: .time(date.formatted(format))
        }
    }
}
