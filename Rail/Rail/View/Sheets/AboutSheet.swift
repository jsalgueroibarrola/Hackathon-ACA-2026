import SwiftData
import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]

    private static let logoHeight: CGFloat = 64
    private static let openDataPortal = URL(string: "https://data.renfe.com")
    private static let reuseConditions = URL(string: "https://data.renfe.com/legal")

    private var lastUpdate: LocalizedStringResource? {
        networks.first.flatMap { network in
            timetables.first.map {
                Self.lastUpdate(
                    $0.lastFetchedAt.formatted(
                        Date.FormatStyle(date: .long, time: .omitted, timeZone: network.calendar.timeZone)
                    )
                )
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ScreenLayout.gutter) {
                    header
                    unofficial
                    dataSource
                    liability
                    signature
                }
                .padding(.horizontal, ScreenLayout.margin)
                .padding(.vertical, Spacing.lg)
                .frame(maxWidth: ScreenLayout.maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(.bgSecondary)
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            RailLogo()
                .frame(height: Self.logoHeight)
            Text(Self.tagline)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .accessibilityElement(children: .combine)
    }

    private var unofficial: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            CardSectionHeader(Self.unofficialTitle, systemImage: "info.circle")
            Text(Self.unofficialBody)
                .font(.body)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardSurface()
    }

    private var dataSource: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            CardSectionHeader(Self.dataSourceTitle, systemImage: "tablecells")
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(Self.dataOrigin)
                    .font(.bodyEmphasized)
                    .foregroundStyle(.textPrimary)
                Text(Self.dataSourceBody)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                if let lastUpdate {
                    Label {
                        Text(lastUpdate)
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                            .accessibilityHidden(true)
                    }
                    .font(.footnote)
                    .foregroundStyle(.textTertiary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            links
                .padding(.top, Spacing.md)
        }
        .cardSurface()
    }

    private var links: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.sm) { linkButtons }
            VStack(alignment: .leading, spacing: Spacing.sm) { linkButtons }
        }
        .buttonStyle(.rail(.bordered))
        .controlSize(.small)
    }

    @ViewBuilder
    private var linkButtons: some View {
        if let url = Self.openDataPortal {
            Link(destination: url) {
                Label(Self.openDataPortalTitle, systemImage: "arrow.up.right")
            }
        }
        if let url = Self.reuseConditions {
            Link(destination: url) {
                Label(Self.reuseConditionsTitle, systemImage: "arrow.up.right")
            }
        }
    }

    private var liability: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            CardSectionHeader(Self.liabilityTitle, systemImage: "exclamationmark.shield")
            Text(Self.liabilityBody)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardSurface()
    }

    private var signature: some View {
        VStack(spacing: Spacing.xxs) {
            Text(Self.madeBy)
                .font(.caption)
                .textCase(.uppercase)
                .tracking(Tracking.wide)
                .foregroundStyle(.textTertiary)
            Text(verbatim: "JadeHorizonStudio")
                .font(.subheadlineEmphasized)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxl)
        .padding(.bottom, Spacing.lg)
        .accessibilityElement(children: .combine)
    }

    static let title = LocalizedStringResource(
        "Información",
        comment: "Título de la hoja «Información» que se abre desde el botón de información de Inicio, y etiqueta de ese botón para VoiceOver."
    )

    private static let tagline = LocalizedStringResource(
        "Horarios de Cercanías Málaga, también sin conexión.",
        comment: "Hoja de información: frase bajo el logotipo que resume qué es la app."
    )

    private static let unofficialTitle = LocalizedStringResource(
        "App no oficial",
        comment: "Hoja de información: cabecera de la tarjeta que aclara que la app no es de Renfe."
    )

    private static let unofficialBody = LocalizedStringResource(
        "Rail es una aplicación independiente. No es una aplicación oficial de Renfe y no está vinculada a Renfe Operadora, que no participa, patrocina ni apoya esta aplicación.",
        comment: "Hoja de información: aviso legal obligatorio de que la app no es oficial ni está respaldada por Renfe."
    )

    private static let dataSourceTitle = LocalizedStringResource(
        "Origen de los datos",
        comment: "Hoja de información: cabecera de la tarjeta sobre la procedencia de los datos."
    )

    private static let dataOrigin = LocalizedStringResource(
        "Origen de los datos: Renfe Operadora",
        comment: "Hoja de información: cita obligatoria de la fuente según las condiciones de reutilización de Renfe. Mantén «Renfe Operadora» sin traducir."
    )

    private static let dataSourceBody = LocalizedStringResource(
        "Los horarios, las estaciones y los avisos proceden de los conjuntos de datos abiertos que Renfe publica en su portal data.renfe.com, y se reutilizan conforme a sus condiciones legales.",
        comment: "Hoja de información: explicación de que los datos son los oficiales publicados por Renfe como datos abiertos."
    )

    private static func lastUpdate(_ date: String) -> LocalizedStringResource {
        LocalizedStringResource(
            "Datos actualizados el \(date)",
            comment: "Hoja de información: fecha de la última descarga de los datos de Renfe. El argumento es la fecha, por ejemplo «27 de septiembre de 2026»."
        )
    }

    private static let openDataPortalTitle = LocalizedStringResource(
        "Datos abiertos de Renfe",
        comment: "Hoja de información: enlace al portal data.renfe.com."
    )

    private static let reuseConditionsTitle = LocalizedStringResource(
        "Condiciones de uso",
        comment: "Hoja de información: enlace a las condiciones legales de reutilización de data.renfe.com/legal."
    )

    private static let liabilityTitle = LocalizedStringResource(
        "Aviso legal",
        comment: "Hoja de información: cabecera de la tarjeta de exención de responsabilidad."
    )

    private static let liabilityBody = LocalizedStringResource(
        "Los horarios pueden cambiar o contener errores. Consulta los canales oficiales de Renfe antes de viajar. Renfe no se hace responsable del uso que esta aplicación hace de sus datos.",
        comment: "Hoja de información: exención de responsabilidad sobre la exactitud de los datos."
    )

    private static let madeBy = LocalizedStringResource(
        "Hecho por",
        comment: "Hoja de información: firma al pie, encima del nombre del estudio «JadeHorizonStudio»."
    )
}

#if DEBUG
    #Preview("Con datos", traits: .stationTimetableSampleData) {
        AboutSheet()
    }

    #Preview("Modo oscuro", traits: .stationTimetableSampleData) {
        AboutSheet()
            .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type", traits: .stationTimetableSampleData) {
        AboutSheet()
            .dynamicTypeSize(.accessibility2)
    }
#endif
