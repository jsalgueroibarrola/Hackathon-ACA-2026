//
//  DTOMapping.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

extension TransitNetwork {
    convenience init(dto: NetworkResponseDTO, etag: String?, fetchedAt: Date) {
        self.init(
            id: dto.network.id,
            name: dto.network.name,
            timeZoneIdentifier: dto.network.timezone,
            version: dto.version,
            etag: etag,
            lastFetchedAt: fetchedAt
        )
    }
}

extension Line {
    convenience init(dto: LineDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            colorHex: dto.color,
            shape: dto.shape
        )
    }
}

extension Station {
    convenience init(dto: StationDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            latitude: dto.lat,
            longitude: dto.lon,
            isAccessible: dto.accessible,
            hasElevator: dto.elevator,
            connections: (dto.connections ?? [])
                .compactMap { StationConnection(rawValue: $0.rawValue) }
        )
    }
}

extension Timetable {
    convenience init(
        dto: TimetableResponseDTO,
        networkID: String,
        startDay: Date,
        endDay: Date,
        etag: String?,
        fetchedAt: Date
    ) {
        self.init(
            networkID: networkID,
            version: dto.version,
            startDay: startDay,
            endDay: endDay,
            etag: etag,
            lastFetchedAt: fetchedAt
        )
    }
}

extension Trip {
    convenience init(dto: TripDTO) {
        self.init(
            lineID: dto.line,
            direction: TripDirection(rawValue: dto.dir) ?? .outbound,
            train: dto.train,
            serviceDays: dto.days,
            times: dto.times
        )
    }
}
