import Foundation
import SwiftData

enum RailWidgetStore {
    private static let container = try? ModelContainer(
        for: RailStore.schema,
        configurations: [RailStore.configuration(allowsSave: false)]
    )

    static func favoriteStations() -> [StationEntity] {
        read { context in
            let favorites = context.fetchAll(
                FetchDescriptor<FavoriteStation>(sortBy: FavoriteStation.order)
            )
            let names = context.stationNames()

            return favorites.compactMap { favorite in
                names[favorite.stationID].map {
                    StationEntity(id: favorite.stationID, name: $0)
                }
            }
        } ?? []
    }

    static func allStations() -> [StationEntity] {
        read { context in
            context
                .fetchAll(
                    FetchDescriptor<Station>(sortBy: [SortDescriptor(\.name)])
                )
                .map { StationEntity(id: $0.id, name: $0.name) }
        } ?? []
    }

    static func stations(withIDs identifiers: [String]) -> [StationEntity] {
        read { context in
            let names = context.stationNames()

            return identifiers.compactMap { identifier in
                names[identifier].map { StationEntity(id: identifier, name: $0) }
            }
        } ?? []
    }

    static func snapshot(stationID: String, now: Date) -> NextTrainsWidgetSnapshot {
        read { context in
            guard
                let network = context.first(TransitNetwork.self),
                let timetable = context.first(Timetable.self)
            else { return .unavailable }

            guard let station = context.station(withID: stationID) else {
                return .unknownStation
            }

            let calendar = network.calendar
            let schedules = { (day: Date) in
                StationScheduleBuilder.schedules(
                    for: station,
                    timetable: timetable,
                    day: day,
                    calendar: calendar,
                    context: context
                )
            }
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)

            return .station(
                NextTrainsWidgetStation(
                    id: station.id,
                    name: station.name,
                    timeZone: network.timeZone,
                    today: rows(from: schedules(now), since: now),
                    firstTomorrow: tomorrow
                        .map(schedules)?
                        .flatMap(\.departures)
                        .map(\.date)
                        .min()
                )
            )
        } ?? .unavailable
    }

    private static func rows(
        from schedules: [StationLineSchedule],
        since date: Date
    ) -> [NextTrainsWidgetRow] {
        schedules
            .flatMap { line in
                line.upcoming(from: date).map { (line: line, departure: $0) }
            }
            .sorted {
                ($0.departure.date, $0.line.lineID)
                    < ($1.departure.date, $1.line.lineID)
            }
            .map {
                NextTrainsWidgetRow(
                    id: $0.departure.id,
                    line: $0.line.lineID,
                    colorHex: $0.line.colorHex,
                    destination: $0.line.destination,
                    date: $0.departure.date
                )
            }
    }

    private static func read<Value>(_ body: (ModelContext) -> Value) -> Value? {
        container.map { body(ModelContext($0)) }
    }
}

private extension ModelContext {
    func fetchAll<Model: PersistentModel>(_ descriptor: FetchDescriptor<Model>) -> [Model] {
        (try? fetch(descriptor)) ?? []
    }

    func stationNames() -> [String: String] {
        Dictionary(
            fetchAll(FetchDescriptor<Station>()).map { ($0.id, $0.name) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func first<Model: PersistentModel>(_ type: Model.Type) -> Model? {
        var descriptor = FetchDescriptor<Model>()
        descriptor.fetchLimit = 1
        return fetchAll(descriptor).first
    }

    func station(withID identifier: String) -> Station? {
        var descriptor = FetchDescriptor<Station>(
            predicate: #Predicate { $0.id == identifier }
        )
        descriptor.fetchLimit = 1
        return fetchAll(descriptor).first
    }
}
