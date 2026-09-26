import Foundation

struct StationTimetableRow: Identifiable, Hashable, Sendable {
    enum Status: Hashable, Sendable {
        case departed
        case next
        case upcoming
    }

    let id: String
    let lineID: String
    let colorHex: String
    let destination: String
    let train: String
    let time: String
    let status: Status
    let minutesAway: Int?

    var isPast: Bool { status == .departed }
}

struct StationTimetable: Hashable, Sendable {
    let departed: [StationTimetableRow]
    let upcoming: [StationTimetableRow]
    let nextDay: [StationTimetableRow]

    var isEmpty: Bool { departed.isEmpty && upcoming.isEmpty && nextDay.isEmpty }

    var hasUpcoming: Bool { !upcoming.isEmpty || !nextDay.isEmpty }
}

struct StationTimetableFilter: Identifiable, Hashable, Sendable {
    let id: String
    let lineID: String
    let destination: String
}

enum StationTimetableBuilder {
    static func days(
        from start: Date,
        through end: Date,
        today: Date,
        calendar: Calendar
    ) -> [Date] {
        let first = max(calendar.startOfDay(for: start), calendar.startOfDay(for: today))
        let last = calendar.startOfDay(for: end)
        return first <= last
            ? Array(
                sequence(first: first) {
                    calendar.date(byAdding: .day, value: 1, to: $0).flatMap { $0 <= last ? $0 : nil }
                }
            )
            : []
    }

    static func filters(_ schedules: [StationLineSchedule]) -> [StationTimetableFilter] {
        schedules.map {
            StationTimetableFilter(id: $0.id, lineID: $0.lineID, destination: $0.destination)
        }
    }

    static func timetable(
        _ schedules: [StationLineSchedule],
        filter: String?,
        serviceDay: Date,
        now: Date,
        calendar: Calendar,
        timeZone: TimeZone
    ) -> StationTimetable {
        let format = Date.FormatStyle.departureTime(in: timeZone)
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: serviceDay))
        let departures = schedules
            .filter { filter == nil || $0.id == filter }
            .flatMap { schedule in schedule.departures.map { (schedule: schedule, departure: $0) } }
            .sorted {
                ($0.departure.date, $0.schedule.lineID) < ($1.departure.date, $1.schedule.lineID)
            }
        let entries = departures.map { item in
            (
                id: "\(item.schedule.id)-\(item.departure.id)",
                isNextDay: nextDayStart.map { item.departure.date >= $0 } ?? false,
                item: item,
                minutes: item.departure.date >= now
                    ? Int(item.departure.date.timeIntervalSince(now) / 60)
                    : nil
            )
        }
        let nextDate = entries.first { $0.minutes != nil }?.item.departure.date
        let rows = entries.map { entry in
            (
                isNextDay: entry.isNextDay,
                row: StationTimetableRow(
                    id: entry.id,
                    lineID: entry.item.schedule.lineID,
                    colorHex: entry.item.schedule.colorHex,
                    destination: entry.item.schedule.destination,
                    train: entry.item.departure.train,
                    time: entry.item.departure.date.formatted(format),
                    status: entry.minutes == nil
                        ? .departed
                        : entry.item.departure.date == nextDate ? .next : .upcoming,
                    minutesAway: entry.minutes.flatMap { $0 < countdownLimit ? $0 : nil }
                )
            )
        }
        let sameDay = rows.filter { !$0.isNextDay }.map(\.row)
        return StationTimetable(
            departed: sameDay.filter(\.isPast),
            upcoming: sameDay.filter { !$0.isPast },
            nextDay: rows.filter(\.isNextDay).map(\.row)
        )
    }

    static let countdownLimit = 60
}
