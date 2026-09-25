import SwiftUI
import WidgetKit

struct NextTrainsWidgetView: View {
    private let entry: NextTrainsWidgetEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(entry: NextTrainsWidgetEntry) {
        self.entry = entry
    }

    var body: some View {
        content
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .widgetURL(entry.deepLink)
            .containerBackground(for: .widget) {
                if isAccessory {
                    Color.clear
                } else {
                    Color.bgPrimary
                }
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
            VStack(alignment: .leading, spacing: Spacing.xs) {
                header(station)
                Text(
                    "No quedan trenes hoy",
                    comment: "Widget de próximos trenes: no hay más salidas en el día."
                )
                .font(.captionEmphasized)
                if let detail = tomorrowDetail(firstTomorrow) {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.textSecondary)
                }
            }
        case .departures(let station, let rows):
            VStack(alignment: .leading, spacing: Spacing.xs) {
                header(station)
                ForEach(rows.prefix(rowLimit)) { row in
                    NextTrainsWidgetRowView(row, timeZone: entry.timeZone)
                }
            }
        }
    }

    private func header(_ station: String) -> some View {
        Text(verbatim: station)
            .font(.captionEmphasized)
            .foregroundStyle(.textSecondary)
            .lineLimit(1)
            .truncationMode(.tail)
    }

    @ViewBuilder
    private func message(
        _ title: LocalizedStringResource,
        detail: LocalizedStringResource,
        symbol: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !isAccessory {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(.textSecondary)
            }
            Text(title)
                .font(.captionEmphasized)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var configureHint: LocalizedStringResource {
        isAccessory
            ? LocalizedStringResource(
                "Personaliza la pantalla de bloqueo y toca el widget.",
                comment: "Widget de próximos trenes: cómo elegir la estación desde la pantalla de bloqueo."
            )
            : LocalizedStringResource(
                "Mantén pulsado y toca «Editar widget».",
                comment: "Widget de próximos trenes: cómo elegir la estación desde la pantalla de inicio."
            )
    }

    private func tomorrowDetail(_ firstTomorrow: Date?) -> LocalizedStringResource? {
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

    private var isAccessory: Bool {
        family == .accessoryRectangular
    }

    private var rowLimit: Int {
        dynamicTypeSize.isAccessibilitySize
            ? max(1, family.maxDepartures / 2)
            : family.maxDepartures
    }
}
