import Foundation

struct TimetableResponseDTO: Decodable, Sendable {
    /// Version of the source feed the timetable was built from. Informative only.
    let version: String
    /// First local day covered by the timetable, inclusive, as `YYYY-MM-DD`.
    let from: String
    /// Last local day covered by the timetable, inclusive, as `YYYY-MM-DD`. There is no data outside this range.
    let to: String
    /// Every trip of the period currently in force.
    let trips: [TripDTO]
}

struct TripDTO: Decodable, Sendable {
    /// Identifier of the line the trip runs on. Points at `LineDTO.id`.
    let line: String
    /// Direction of travel: `0` follows `LineDTO.stations` in order, `1` follows it reversed.
    let dir: Int
    /// Renfe train number, meant for display. Not unique on its own.
    let train: String
    /// One digit per service day from `from` to `to`, where `1` means the trip runs that day and `0` means it does not.
    let days: String
    /// Minutes since local midnight of the service day, one per station of the route in the given direction. Departure time at every station, arrival time at the last one.
    let times: [Int]
}
