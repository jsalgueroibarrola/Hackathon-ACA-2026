import Foundation

struct JourneyTimetableRow: Identifiable, Hashable, Sendable {
    let id: String
    let departure: String
    let arrival: String
    let durationMinutes: Int
    let lines: [JourneyLineMark]
    let train: String
    let headsign: String
    let transferStation: String?
    let transferMinutes: Int?
    let status: StationTimetableRow.Status
    let minutesAway: Int?

    var isPast: Bool { status == .departed }
}

struct JourneyLineMark: Identifiable, Hashable, Sendable {
    let id: String
    let lineID: String
    let colorHex: String
}

struct JourneyTimetable: Hashable, Sendable {
    let departed: [JourneyTimetableRow]
    let upcoming: [JourneyTimetableRow]
    let nextDay: [JourneyTimetableRow]

    var isEmpty: Bool { departed.isEmpty && upcoming.isEmpty && nextDay.isEmpty }

    var hasUpcoming: Bool { !upcoming.isEmpty || !nextDay.isEmpty }
}

struct JourneySummary: Hashable, Sendable {
    let count: Int
    let lines: [JourneyLineMark]
}

enum JourneyTimetableBuilder {
    static func summary(_ journeys: [Journey]) -> JourneySummary {
        JourneySummary(
            count: journeys.count,
            lines: uniqueLines(journeys.flatMap(\.legs))
        )
    }

    static func timetable(
        _ journeys: [Journey],
        serviceDay: Date,
        now: Date,
        calendar: Calendar,
        timeZone: TimeZone
    ) -> JourneyTimetable {
        let format = Date.FormatStyle.departureTime(in: timeZone)
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: serviceDay))
        let nextDate = journeys.first { $0.departure >= now }?.departure
        let rows = journeys.map { journey in
            let minutes = journey.departure >= now ? Int(journey.departure.timeIntervalSince(now) / 60) : nil
            return (
                isNextDay: nextDayStart.map { journey.departure >= $0 } ?? false,
                row: JourneyTimetableRow(
                    id: journey.id,
                    departure: journey.departure.formatted(format),
                    arrival: journey.arrival.formatted(format),
                    durationMinutes: journey.durationMinutes,
                    lines: journey.legs.map {
                        JourneyLineMark(id: $0.id, lineID: $0.lineID, colorHex: $0.colorHex)
                    },
                    train: journey.first.train,
                    headsign: journey.first.headsign,
                    transferStation: journey.transferStation,
                    transferMinutes: journey.transferMinutes,
                    status: minutes == nil
                        ? .departed
                        : journey.departure == nextDate ? .next : .upcoming,
                    minutesAway: minutes.flatMap { $0 < StationTimetableBuilder.countdownLimit ? $0 : nil }
                )
            )
        }
        let sameDay = rows.filter { !$0.isNextDay }.map(\.row)
        return JourneyTimetable(
            departed: sameDay.filter(\.isPast),
            upcoming: sameDay.filter { !$0.isPast },
            nextDay: rows.filter(\.isNextDay).map(\.row)
        )
    }

    private static func uniqueLines(_ legs: [JourneyLeg]) -> [JourneyLineMark] {
        legs.reduce(into: [JourneyLineMark]()) { marks, leg in
            if !marks.contains(where: { $0.lineID == leg.lineID }) {
                marks.append(JourneyLineMark(id: leg.lineID, lineID: leg.lineID, colorHex: leg.colorHex))
            }
        }
    }
}
