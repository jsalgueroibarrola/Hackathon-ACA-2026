//
//  DTOMapping.swift
//  Rail
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

extension ServiceAlertFeed {
    convenience init(
        dto: AlertsResponseDTO,
        etag: String?,
        freshness: CacheFreshness,
        fetchedAt: Date,
        fallbackInterval: Duration
    ) {
        self.init(
            etag: etag,
            feedTimestamp: dto.ts.map(Date.init(unixSeconds:)),
            fetchedAt: fetchedAt,
            expiresAt: freshness.expiry(from: fetchedAt, fallback: fallbackInterval),
            isStale: freshness.isStale
        )
    }
}

extension ServiceAlert {
    convenience init(dto: ServiceAlertDTO, position: Int) {
        self.init(
            id: dto.id,
            kind: AlertKind(rawValue: dto.kind.rawValue) ?? .other,
            lineIDs: dto.lines,
            since: dto.since.map(Date.init(unixSeconds:)),
            until: dto.until.map(Date.init(unixSeconds:)),
            text: dto.text,
            position: position
        )
    }
}

extension RealtimeFeed {
    convenience init(
        dto: RealtimeResponseDTO,
        etag: String?,
        freshness: CacheFreshness,
        fetchedAt: Date,
        fallbackInterval: Duration
    ) {
        self.init(
            etag: etag,
            feedTimestamp: dto.ts.map(Date.init(unixSeconds:)),
            isPartial: dto.partial ?? false,
            fetchedAt: fetchedAt,
            expiresAt: freshness.expiry(from: fetchedAt, fallback: fallbackInterval),
            isStale: freshness.isStale
        )
    }
}

extension LiveTrain {
    convenience init(dto: LiveTrainDTO, calendar: Calendar) {
        self.init(
            lineID: dto.line,
            train: dto.train,
            serviceDay: dto.serviceDay.flatMap(calendar.serviceDay(from:)),
            delaySeconds: dto.delay,
            status: LiveStatus(rawValue: dto.status.rawValue) ?? .unknown,
            stopID: dto.stop,
            nextStopID: dto.next,
            latitude: dto.lat,
            longitude: dto.lon,
            platform: dto.platform,
            sampledAt: dto.at.map(Date.init(unixSeconds:))
        )
    }
}

private extension Date {
    init(unixSeconds: Int) {
        self.init(timeIntervalSince1970: TimeInterval(unixSeconds))
    }
}
