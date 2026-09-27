import SwiftUI
import WidgetKit

struct NextTrainsWidgetView: View {
    private let entry: NextTrainsWidgetEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetContentMargins) private var contentMargins

    init(entry: NextTrainsWidgetEntry) {
        self.entry = entry
    }

    var body: some View {
        content
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .widgetURL(entry.deepLink)
            .containerBackground(for: .widget) {
                Color.bgPrimary
            }
    }

    @ViewBuilder
    private var content: some View {
        switch entry.content {
        case .unconfigured:
            message(
                LocalizedStringResource(
                    "Elige una estación",
                    comment: "Widget de próximos trenes: título cuando nadie ha configurado el widget todavía."
                ),
                detail: configureHint,
                symbol: "tram.fill"
            )
        case .dataMissing:
            message(
                LocalizedStringResource(
                    "Sin horarios",
                    comment: "Widget de próximos trenes: título cuando no hay datos descargados."
                ),
                detail: LocalizedStringResource(
                    "Abre Rail para descargar los horarios.",
                    comment: "Widget de próximos trenes: invita a abrir la app porque el widget no sincroniza."
                ),
                symbol: "arrow.down.circle"
            )
        case .unknownStation:
            message(
                LocalizedStringResource(
                    "Estación no disponible",
                    comment: "Widget de próximos trenes: título cuando la estación configurada ya no está en los datos."
                ),
                detail: configureHint,
                symbol: "questionmark.circle"
            )
        case .noService(let station, let firstTomorrow):
            VStack(alignment: .leading, spacing: Spacing.sm) {
                header(station)
                Spacer(minLength: Spacing.none)
                messageBody(
                    endOfServiceTitle,
                    detail: Text(tomorrowDetail(firstTomorrow)),
                    symbol: "moon.zzz.fill"
                )
            }
        case .departures(let station, let rows):
            switch family {
            case .systemSmall:
                smallDepartures(station, rows: rows)
            default:
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    header(station)
                    fitting(rows) { visible in
                        departureList(visible)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
    }

    private func smallDepartures(_ station: String, rows: [NextTrainsWidgetRow]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.none) {
            Text(verbatim: station)
                .font(.captionEmphasized)
                .foregroundStyle(.textSecondary)
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer(minLength: Spacing.xs)
            if let first = rows.first {
                ViewThatFits(in: .vertical) {
                    hero(first, showsCountdown: true)
                    hero(first, showsCountdown: false)
                }
            }
        }
    }

    private func hero(_ row: NextTrainsWidgetRow, showsCountdown: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            ViewThatFits(in: .horizontal) {
                heroDestination(row, showsArrow: true)
                heroDestination(row, showsArrow: false)
            }
            Text(row.date, format: Date.FormatStyle.departureTime(in: entry.timeZone))
                .font(.timeDepartureHero)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if showsCountdown {
                Text(.currentDate, format: .reference(to: row.date, allowedFields: [.hour, .minute]))
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func heroDestination(_ row: NextTrainsWidgetRow, showsArrow: Bool) -> some View {
        HStack(spacing: Spacing.xs) {
            NextTrainsWidgetLineMark(row)
            if showsArrow {
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }
            Text(verbatim: row.destination)
                .font(.subheadlineEmphasized)
                .lineLimit(1)
                .minimumScaleFactor(showsArrow ? 1 : 0.85)
                .truncationMode(.tail)
        }
    }

    private func departureList(_ rows: ArraySlice<NextTrainsWidgetRow>) -> some View {
        VStack(alignment: .leading, spacing: Spacing.none) {
            ForEach(rows) { row in
                NextTrainsWidgetRowView(
                    row,
                    timeZone: entry.timeZone,
                    showsSeparator: row.id != rows.last?.id
                )
            }
        }
    }

    private func fitting<Content: View>(
        _ rows: [NextTrainsWidgetRow],
        @ViewBuilder content: @escaping (ArraySlice<NextTrainsWidgetRow>) -> Content
    ) -> some View {
        ViewThatFits(in: .vertical) {
            ForEach((1...max(1, rows.count)).reversed(), id: \.self) { count in
                content(rows.prefix(count))
            }
        }
    }

    private func header(_ station: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(verbatim: station)
                    .font(family == .systemLarge ? .title3Emphasized : .headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Label {
                    Text(
                        "Próximos trenes",
                        comment: "Widget de próximos trenes: cabecera de la lista de salidas de la estación."
                    )
                } icon: {
                    Image(systemName: "clock")
                }
                .labelIconToTitleSpacing(Spacing.xs)
                .font(.footnote)
                .foregroundStyle(.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            if family != .systemSmall {
                illustration
            }
        }
    }

    private var illustration: some View {
        Image(.trenecitoInicio)
            .resizable()
            .widgetAccentedRenderingMode(.desaturated)
            .scaledToFit()
            .frame(height: family == .systemLarge ? Size.iconLg + Spacing.md : Size.iconLg)
            .padding(.trailing, -contentMargins.trailing)
            .accessibilityHidden(true)
    }

    private var endOfServiceTitle: Text {
        Text(
            "No quedan trenes hoy",
            comment: "Widget de próximos trenes: no hay más salidas en el día."
        )
    }

    @ViewBuilder
    private func message(
        _ title: LocalizedStringResource,
        detail: LocalizedStringResource,
        symbol: String
    ) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.none) {
                Spacer(minLength: Spacing.none)
                messageBody(Text(title), detail: Text(detail), symbol: symbol)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if family != .systemSmall {
                illustration
            }
        }
    }

    private func messageBody(_ title: Text, detail: Text?, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.brandPrimary)
                .widgetAccentable()
                .accessibilityHidden(true)
                .padding(.bottom, Spacing.xs)
            title
                .font(.subheadlineEmphasized)
            if let detail {
                detail
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var configureHint: LocalizedStringResource {
        LocalizedStringResource(
            "Mantén pulsado y toca «Editar widget».",
            comment: "Widget de próximos trenes: cómo elegir la estación desde la pantalla de inicio."
        )
    }

    private func tomorrowDetail(_ firstTomorrow: Date?) -> LocalizedStringResource {
        guard let firstTomorrow else {
            return LocalizedStringResource(
                "Abre Rail para actualizar los horarios.",
                comment: "Widget de próximos trenes: no hay datos del día siguiente y hay que sincronizar."
            )
        }

        return LocalizedStringResource(
            "Primera salida mañana a las \(firstTomorrow.formatted(Date.FormatStyle.departureTime(in: entry.timeZone)))",
            comment: "Widget de próximos trenes: hora de la primera salida del día siguiente, por ejemplo «05:40»."
        )
    }
}
