import Foundation
import SwiftData

@Model
final class TransitNetwork {
    #Unique<TransitNetwork>([\.id])

    /// Identifier of the network, for example `malaga`.
    var id: String
    /// Display name of the network.
    var name: String
    /// IANA time zone every timetable is expressed in, for example `Europe/Madrid`. Read it through ``timeZone``.
    var timeZoneIdentifier: String
    /// Date the payload was generated, as `YYYY-MM-DD`. Informative only: ``etag`` is what tells the data apart.
    var version: String
    /// `ETag` of the response the data was built from, for conditional requests. `nil` until the server sends one.
    var etag: String?
    /// When the payload was last downloaded, so the app can decide whether revalidating is worth it.
    var lastFetchedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Line.network)
    var lines: [Line]

    @Relationship(deleteRule: .cascade, inverse: \Station.network)
    var stations: [Station]

    init(
        id: String,
        name: String,
        timeZoneIdentifier: String,
        version: String,
        etag: String? = nil,
        lastFetchedAt: Date
    ) {
        self.id = id
        self.name = name
        self.timeZoneIdentifier = timeZoneIdentifier
        self.version = version
        self.etag = etag
        self.lastFetchedAt = lastFetchedAt
        self.lines = []
        self.stations = []
    }
}

extension TransitNetwork {
    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .gmt
    }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
