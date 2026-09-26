import Foundation
import SwiftData

@ModelActor
actor SwiftDataTransitRepository: TransitRepository {

    private static let tripBatchSize = 500

    func localState() async throws -> LocalDataState {
        let network = try modelContext.first(TransitNetwork.self)
        let timetable = try modelContext.first(Timetable.self)

        return LocalDataState(
            networkID: network?.id,
            timeZoneIdentifier: network?.timeZoneIdentifier,
            networkETag: network?.etag,
            timetableETag: timetable?.etag,
            startDay: timetable?.startDay,
            endDay: timetable?.endDay,
            lastFetchedAt: [network?.lastFetchedAt, timetable?.lastFetchedAt]
                .compactMap(\.self)
                .min()
        )
    }

    func importNetwork(
        _ dto: NetworkResponseDTO,
        etag: String?,
        fetchedAt: Date
    ) async throws {
        try modelContext.commit {
            try modelContext.deleteAll(TransitNetwork.self)

            let network = TransitNetwork(dto: dto, etag: etag, fetchedAt: fetchedAt)
            modelContext.insert(network)

            let stations = dto.stations.map(Station.init(dto:))
            stations.forEach { $0.network = network }
            modelContext.insertAll(stations)

            let stationsByID = Dictionary(
                stations.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )

            let lines = dto.lines.map(Line.init(dto:))
            lines.forEach { $0.network = network }
            modelContext.insertAll(lines)

            let stops = zip(lines, dto.lines).flatMap { line, lineDTO in
                lineDTO.stations.enumerated().map { sequence, stationID in
                    let stop = LineStop(
                        lineID: line.id,
                        stationID: stationID,
                        sequence: sequence
                    )
                    stop.line = line
                    stop.station = stationsByID[stationID]
                    return stop
                }
            }
            modelContext.insertAll(stops)
        }
    }

    func importTimetable(
        _ dto: TimetableResponseDTO,
        etag: String?,
        fetchedAt: Date
    ) async throws {
        guard let network = try modelContext.first(TransitNetwork.self) else {
            throw TransitRepositoryError.missingNetwork
        }

        let calendar = network.calendar

        guard let startDay = calendar.serviceDay(from: dto.from) else {
            throw TransitRepositoryError.invalidDay(dto.from)
        }
        guard let endDay = calendar.serviceDay(from: dto.to) else {
            throw TransitRepositoryError.invalidDay(dto.to)
        }

        let timetable = Timetable(
            dto: dto,
            networkID: network.id,
            startDay: startDay,
            endDay: endDay,
            etag: etag,
            fetchedAt: fetchedAt
        )

        try modelContext.commit {
            try modelContext.deleteAll(Trip.self)
            try modelContext.deleteAll(Timetable.self)
            modelContext.insert(timetable)

            try dto.trips.chunks(of: Self.tripBatchSize).forEach { batch in
                try Task.checkCancellation()

                let trips = batch.map(Trip.init(dto:))
                trips.forEach { $0.timetable = timetable }
                modelContext.insertAll(trips)
            }

            try Task.checkCancellation()
        }
    }

    func markRevalidated(
        network: Bool,
        timetable: Bool,
        fetchedAt: Date
    ) async throws {
        try modelContext.commit {
            if network, let stored = try modelContext.first(TransitNetwork.self) {
                stored.lastFetchedAt = fetchedAt
            }
            if timetable, let stored = try modelContext.first(Timetable.self) {
                stored.lastFetchedAt = fetchedAt
            }
        }
    }
}
