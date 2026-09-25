import Foundation

struct ServiceAlertItem: Identifiable, Hashable, Sendable {
    let id: String
    let kind: AlertKind
    let text: String
    let time: String?
    let lines: [LineTag]
}

enum ServiceAlertItemBuilder {
    static func items(
        alerts: [ServiceAlert],
        lines: [Line],
        now: Date,
        calendar: Calendar,
        locale: Locale,
        dateLocale: Locale
    ) -> [ServiceAlertItem] {
        let tagsByID = Dictionary(
            lines.map { ($0.id, LineTag(id: $0.id, colorHex: $0.colorHex)) },
            uniquingKeysWith: { first, _ in first }
        )
        let active = alerts
            .sorted { $0.position < $1.position }
            .filter { $0.until.map { $0 > now } ?? true }
        let firstIndexByID = Dictionary(
            active.enumerated().map { ($1.id, $0) },
            uniquingKeysWith: min
        )

        return
            active
            .enumerated()
            .filter { index, alert in firstIndexByID[alert.id] == index }
            .map { _, alert in
                ServiceAlertItem(
                    id: alert.id,
                    kind: alert.kind,
                    text: alert.text,
                    time: AlertTimestamp.text(
                        since: alert.since,
                        now: now,
                        calendar: calendar,
                        locale: locale,
                        dateLocale: dateLocale
                    ),
                    lines: alert.lineIDs.compactMap { tagsByID[$0] }
                )
            }
    }
}
