import SwiftData
import SwiftUI

struct NearbyStationCard: View {
    private let item: NearbyStationItem
    private let liveTrains: [String: NearbyLiveTrain]

    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @State private var schedules: NextTrainsSchedules?

    init(_ item: NearbyStationItem, liveTrains: [String: NearbyLiveTrain] = [:]) {
        self.item = item
        self.liveTrains = liveTrains
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let departures = departures(at: context.date)
            NearbyStationCardContent(item, departures: departures)
                .glassEffect(
                    .regular.interactive(),
                    in: .rect(cornerRadius: Radius.xl)
                )
                .anchorPreference(key: MapBottomAnchors.self, value: .bounds) {
                    [
                        item.id: MapBottomCardAnchor(
                            bounds: $0,
                            item: item,
                            departures: departures
                        )
                    ]
                }
                .loadSchedules(
                    scheduleRequest(at: context.date),
                    into: $schedules
                ) {
                    try await $0.nextTrains(for: $1)
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text(Self.openHint))
    }

    private func departures(at date: Date) -> NearbyDepartures {
        guard timetables.first != nil else {
            return .finished(firstTomorrow: nil)
        }
        return schedules.flatMap {
            $0.stationID == item.id
                ? NearbyDeparturesBuilder.departures(
                    from: $0,
                    liveTrains: liveTrains,
                    now: date
                )
                : nil
        } ?? .loading
    }

    private func scheduleRequest(at date: Date) -> ScheduleRequest? {
        ScheduleRequest(
            stationID: item.id,
            timetable: timetables.first,
            network: networks.first,
            at: date
        )
    }

    private static let openHint = LocalizedStringResource(
        "Abre la ficha de la estación",
        comment:
            "Mapa, carrusel de estaciones cercanas: pista de VoiceOver de cada tarjeta."
    )
}

struct NearbyStationCardContent: View {
    private let item: NearbyStationItem
    private let departures: NearbyDepartures

    init(_ item: NearbyStationItem, departures: NearbyDepartures) {
        self.item = item
        self.departures = departures
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(verbatim: item.row.name)
                    .font(.headline)
                    .foregroundStyle(.glassText)
                    .lineLimit(1)
                summary
            }
            NearbyDepartureSlots(departures)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var summary: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(item.row.lines) { line in
                LineBadge(line.id, color: Color(hex: line.colorHex))
            }
            if item.isAccessible {
                Image(systemName: "figure.roll")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .padding(.leading, Spacing.xxs)
                    .accessibilityLabel(Text(Self.accessibleLabel))
            }
            Spacer(minLength: Spacing.sm)
            if let distance = item.row.distance {
                Text(.distanceAway(distance))
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .monospacedDigit()
            }
        }
        .frame(minHeight: Size.buttonSm)
    }

    private static let accessibleLabel = LocalizedStringResource(
        "Accesible",
        comment:
            "VoiceOver, pin de estación en el mapa: la estación es accesible para movilidad reducida."
    )
}

private struct NearbyDepartureSlots: View {
    private let departures: NearbyDepartures

    init(_ departures: NearbyDepartures) {
        self.departures = departures
    }

    var body: some View {
        placeholder
            .hidden()
            .accessibilityHidden(true)
            .overlay(alignment: .topLeading) {
                content
            }
    }

    private var placeholder: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ForEach(Self.placeholderRows) { row in
                NearbyDepartureRow(row, tint: .fillTertiary)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch departures {
        case .upcoming(let rows):
            VStack(alignment: .leading, spacing: Spacing.xs) {
                ForEach(rows) { row in
                    NearbyDepartureRow(row)
                }
            }
        case .loading:
            placeholder
                .redacted(reason: .placeholder)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(Self.loadingLabel))
        case .finished(let firstTomorrow):
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Label {
                    Text(Self.finishedTitle)
                } icon: {
                    Image(systemName: "moon.zzz")
                }
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                if let firstTomorrow {
                    Text(Self.firstTomorrow(firstTomorrow))
                        .font(.footnote)
                        .foregroundStyle(.textTertiary)
                        .monospacedDigit()
                }
            }
            .lineLimit(1)
            .accessibilityElement(children: .combine)
        }
    }

    private static let placeholderRows = [
        NearbyDeparture(
            id: "placeholder-0",
            lineID: "C-1",
            colorHex: "",
            destination: "Málaga Centro Alameda",
            wait: .minutes(10),
            delayMinutes: nil
        ),
        NearbyDeparture(
            id: "placeholder-1",
            lineID: "C-1",
            colorHex: "",
            destination: "Fuengirola",
            wait: .minutes(20),
            delayMinutes: nil
        ),
    ]

    private static let loadingLabel = LocalizedStringResource(
        "Cargando próximos trenes",
        comment:
            "Tarjeta de próximos trenes: descripción para VoiceOver mientras se calculan las salidas."
    )

    private static let finishedTitle = LocalizedStringResource(
        "No quedan trenes hoy",
        comment:
            "Tarjeta de próximos trenes: título cuando ya no hay más salidas en el día."
    )

    private static func firstTomorrow(_ time: String) -> LocalizedStringResource
    {
        LocalizedStringResource(
            "Primera salida mañana a las \(time)",
            comment:
                "Tarjeta de próximos trenes: hora de la primera salida del día siguiente, por ejemplo «05:40»."
        )
    }
}

private struct NearbyDepartureRow: View {
    private let departure: NearbyDeparture
    private let tint: Color

    init(_ departure: NearbyDeparture, tint: Color? = nil) {
        self.departure = departure
        self.tint = tint ?? Color(hex: departure.colorHex)
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "arrow.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(verbatim: departure.destination)
                .font(.subheadline)
                .foregroundStyle(.glassText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let delay = departure.delayMinutes {
                Text(Self.delay(delay))
                    .font(.captionEmphasized)
                    .foregroundStyle(.transitDelayedText)
                    .monospacedDigit()
                    .fixedSize()
            }
            Text(waitText)
                .font(.timeDeparture)
                .foregroundStyle(.glassText)
                .lineLimit(1)
                .fixedSize()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text(Self.lineLabel(departure.lineID, departure.destination))
        )
        .accessibilityValue(accessibilityValue)
    }

    private var waitText: LocalizedStringResource {
        switch departure.wait {
        case .now:
            LocalizedStringResource(
                "Ahora",
                comment: "Horarios: el tren sale en menos de un minuto."
            )
        case .minutes(let minutes):
            LocalizedStringResource(
                "\(minutes) min",
                comment:
                    "Horarios: minutos que faltan para la salida, por ejemplo «5 min»."
            )
        case .time(let time):
            LocalizedStringResource(stringLiteral: time)
        }
    }

    private var accessibilityValue: Text {
        departure.delayMinutes.map {
            Text(
                "\(Text(waitText)), \(Text(Self.delayDescription($0)))",
                comment:
                    "Mapa: lectura de VoiceOver de la espera de un tren seguida de su retraso, por ejemplo «5 min, con 3 minutos de retraso»."
            )
        } ?? Text(waitText)
    }

    private static func lineLabel(_ lineID: String, _ destination: String)
        -> LocalizedStringResource
    {
        LocalizedStringResource(
            "Línea \(lineID) hacia \(destination)",
            comment:
                "Mapa, carrusel de estaciones cercanas: lectura de VoiceOver del próximo tren de un sentido; línea y destino, por ejemplo «Línea C-1 hacia Fuengirola»."
        )
    }

    private static func delay(_ minutes: Int) -> LocalizedStringResource {
        LocalizedStringResource(
            "+\(minutes) min",
            comment:
                "Mapa, carrusel de estaciones cercanas: retraso en tiempo real del próximo tren, junto a los minutos que faltan; por ejemplo «+3 min»."
        )
    }

    private static func delayDescription(_ minutes: Int)
        -> LocalizedStringResource
    {
        LocalizedStringResource(
            "con \(minutes) minutos de retraso",
            comment:
                "Mapa: retraso de un tren en tiempo real, leído por VoiceOver tras su descripción y una coma, por ejemplo «con 3 minutos de retraso»."
        )
    }
}

#if DEBUG
    extension NearbyStationItem {
        fileprivate static let alameda = NearbyStationItem(
            row: StationRowItem(
                id: "54413",
                name: "Málaga-Centro Alameda",
                subtitle: "Metro · Autobús urbano",
                distance: "350 m",
                lines: [
                    LineTag(id: "C1", colorHex: "DA291C"),
                    LineTag(id: "C2", colorHex: "0057A8"),
                ]
            ),
            isAccessible: true
        )

        fileprivate static let laColina = NearbyStationItem(
            row: StationRowItem(
                id: "54500",
                name: "La Colina",
                subtitle: nil,
                distance: "1,4 km",
                lines: [LineTag(id: "C1", colorHex: "DA291C")]
            ),
            isAccessible: false
        )
    }

    extension NearbyDepartures {
        fileprivate static let alameda = NearbyDepartures.upcoming([
            NearbyDeparture(
                id: "C1-0",
                lineID: "C1",
                colorHex: "DA291C",
                destination: "Fuengirola",
                wait: .minutes(4),
                delayMinutes: nil
            ),
            NearbyDeparture(
                id: "C2-0",
                lineID: "C2",
                colorHex: "0057A8",
                destination: "Álora",
                wait: .minutes(12),
                delayMinutes: 3
            ),
        ])

        fileprivate static let laColina = NearbyDepartures.upcoming([
            NearbyDeparture(
                id: "C1-1",
                lineID: "C1",
                colorHex: "DA291C",
                destination: "Málaga Centro Alameda",
                wait: .now,
                delayMinutes: nil
            ),
            NearbyDeparture(
                id: "C1-0",
                lineID: "C1",
                colorHex: "DA291C",
                destination: "Fuengirola",
                wait: .time("22:41"),
                delayMinutes: nil
            ),
        ])
    }

    private struct NearbyStationCardSamples: View {
        private let samples: [(NearbyStationItem, NearbyDepartures)] = [
            (.alameda, .alameda),
            (.laColina, .laColina),
            (.alameda, .loading),
            (.laColina, .finished(firstTomorrow: "05:40")),
        ]

        var body: some View {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(samples.indices, id: \.self) { index in
                        NearbyStationCardContent(
                            samples[index].0,
                            departures: samples[index].1
                        )
                        .glassEffect(
                            .regular,
                            in: .rect(cornerRadius: Radius.xl)
                        )
                    }
                }
                .padding(ScreenLayout.margin)
            }
            .background(
                LinearGradient(
                    colors: [.green.opacity(0.4), .blue.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    #Preview("Tarjetas") {
        NearbyStationCardSamples()
    }

    #Preview("Modo oscuro") {
        NearbyStationCardSamples()
            .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type") {
        NearbyStationCardSamples()
            .dynamicTypeSize(.accessibility2)
    }
#endif
