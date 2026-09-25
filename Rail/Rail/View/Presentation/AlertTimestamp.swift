import Foundation

enum AlertTimestamp {
    static func text(
        since: Date?,
        now: Date,
        calendar: Calendar,
        locale: Locale,
        dateLocale: Locale
    ) -> String? {
        since.map { since in
            switch now.timeIntervalSince(since) {
            case -60..<60:
                String(localized: justNow)
            case 60..<86_400:
                Date.AnchoredRelativeFormatStyle(
                    anchor: since,
                    allowedFields: [.minute, .hour],
                    presentation: .numeric,
                    unitsStyle: .abbreviated,
                    locale: locale,
                    calendar: calendar,
                    capitalizationContext: .beginningOfSentence
                )
                .format(now)
            default:
                String(
                    localized: sinceDay(
                        day(since, now: now, calendar: calendar, locale: dateLocale)
                    )
                )
            }
        }
    }

    static func dateLocale(preferredLanguages: [String]) -> Locale {
        preferredLanguages.first.map(Locale.init(identifier:)) ?? .autoupdatingCurrent
    }

    static func twoDigitPattern(_ pattern: String) -> String {
        pattern
            .replacing(/d+/, with: "dd")
            .replacing(/M+/, with: "MM")
    }

    private static func day(
        _ date: Date,
        now: Date,
        calendar: Calendar,
        locale: Locale
    ) -> String {
        let template =
            calendar.isDate(date, equalTo: now, toGranularity: .year)
            ? "ddMM" : "ddMMyyyy"
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = twoDigitPattern(
            DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: locale)
                ?? "dd/MM"
        )
        return formatter.string(from: date)
    }

    private static let justNow = LocalizedStringResource(
        "Ahora",
        comment:
            "Notificaciones: hora de un aviso publicado hace menos de un minuto. Va en la esquina de la tarjeta, donde en otros avisos pone «Hace 12 min»."
    )

    private static func sinceDay(_ day: String) -> LocalizedStringResource {
        LocalizedStringResource(
            "Desde \(day)",
            comment:
                "Notificaciones: fecha de un aviso publicado hace más de un día, por ejemplo «Desde 21/09». La variable es el día y el mes, y el año si no es el actual."
        )
    }
}
