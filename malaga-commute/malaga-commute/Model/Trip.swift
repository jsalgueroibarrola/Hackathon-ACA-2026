import Foundation
import SwiftData

@Model
final class Trip {
    #Unique<Trip>([\.id])
    #Index<Trip>([\.lineID, \.directionRaw, \.firstDepartureMinute])

    /// Deterministic key built from the fields that identify a trip in the payload, since it carries no id
    /// and ``train`` repeats.
    var id: String
    /// ``Line/id`` of the line the trip runs on. A plain reference, not a relationship: see ``Timetable``.
    var lineID: String
    /// Raw `dir` from the payload. Stored instead of ``direction`` so indexes and predicates can use it.
    var directionRaw: Int
    /// Renfe train number, meant for display. Not unique on its own.
    var train: String
    /// One digit per service day from ``Timetable/startDay`` to ``Timetable/endDay``, `1` when the trip runs that day.
    var serviceDays: String
    /// Minutes since local midnight of the service day, one per stop of the route in ``direction`` order.
    /// Departure time at every stop, arrival time at the last one.
    var times: [Int]
    /// First entry of ``times``, stored so trips sort and filter by departure without unpacking the array.
    var firstDepartureMinute: Int

    var timetable: Timetable?

    init(lineID: String, direction: TripDirection, train: String, serviceDays: String, times: [Int]) {
        self.id = "\(lineID)-\(direction.rawValue)-\(train)-\(times.first ?? -1)"
        self.lineID = lineID
        self.directionRaw = direction.rawValue
        self.train = train
        self.serviceDays = serviceDays
        self.times = times
        self.firstDepartureMinute = times.first ?? 0
    }
}

extension Trip {
    var direction: TripDirection {
        TripDirection(rawValue: directionRaw) ?? .outbound
    }

    func runs(onDayOffset dayOffset: Int) -> Bool {
        guard dayOffset >= 0,
              let index = serviceDays.index(
                  serviceDays.startIndex,
                  offsetBy: dayOffset,
                  limitedBy: serviceDays.endIndex
              ),
              index < serviceDays.endIndex
        else { return false }
        return serviceDays[index] == "1"
    }

    func minute(atStopSequence sequence: Int, stopCount: Int) -> Int? {
        let index = switch direction {
        case .outbound: sequence
        case .inbound: stopCount - 1 - sequence
        }
        guard times.indices.contains(index) else { return nil }
        return times[index]
    }
}

enum TripDirection: Int, Codable, CaseIterable, Sendable {
    case outbound = 0
    case inbound = 1
}
