import Foundation
import SwiftData

@Model
final class Timetable {
    #Unique<Timetable>([\.networkID])

    /// ``TransitNetwork/id`` the timetable belongs to.
    var networkID: String
    /// Version of the source feed the timetable was built from. Informative only: ``etag`` is what tells the data apart.
    var version: String
    /// Midnight of the first service day covered, inclusive, in the network time zone.
    var startDay: Date
    /// Midnight of the last service day covered, inclusive, in the network time zone. There is no data past it.
    var endDay: Date
    /// `ETag` of the response the data was built from, for conditional requests. `nil` until the server sends one.
    var etag: String?
    /// When the payload was last downloaded, so the app can decide whether revalidating is worth it.
    var lastFetchedAt: Date

    /// Every trip of the period. Owned by the timetable, so replacing the period deletes them.
    /// There are thousands: read them with a `FetchDescriptor<Trip>` filtered by line and direction,
    /// which the indexes on ``Trip`` cover. Touching this array faults all of them at once.
    @Relationship(deleteRule: .cascade, inverse: \Trip.timetable)
    var trips: [Trip]

    init(
        networkID: String,
        version: String,
        startDay: Date,
        endDay: Date,
        etag: String? = nil,
        lastFetchedAt: Date
    ) {
        self.networkID = networkID
        self.version = version
        self.startDay = startDay
        self.endDay = endDay
        self.etag = etag
        self.lastFetchedAt = lastFetchedAt
        self.trips = []
    }
}

extension Timetable {
    func dayOffset(for day: Date, calendar: Calendar) -> Int? {
        let start = calendar.startOfDay(for: startDay)
        let end = calendar.startOfDay(for: endDay)
        let target = calendar.startOfDay(for: day)
        guard target >= start, target <= end else { return nil }
        return calendar.dateComponents([.day], from: start, to: target).day
    }
}
