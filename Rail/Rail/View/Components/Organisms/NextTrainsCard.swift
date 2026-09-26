import SwiftUI

struct NextTrainsCard: View {
    private static let trainHeight: CGFloat = 53
    private static let trainTopInset: CGFloat = 5

    private let state: NextTrainsCardState
    private let onAction: (NextTrainsCardAction) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        _ state: NextTrainsCardState,
        onAction: @escaping (NextTrainsCardAction) -> Void
    ) {
        self.state = state
        self.onAction = onAction
    }

    var body: some View {
        content
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .bgPrimary,
                in: .rect(cornerRadius: Radius.md, style: .continuous)
            )
            .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .station(let station):
            stationContent(station)
        case .locating:
            CardMessage(
                LocalizedStringResource(
                    "Buscando tu ubicación…",
                    comment:
                        "Tarjeta de próximos trenes: título mientras se obtiene la ubicación del usuario."
                ),
                icon: .progress,
                secondary: action(.chooseStation)
            )
        case .permissionNeeded:
            CardMessage(
                LocalizedStringResource(
                    "Activa la ubicación",
                    comment:
                        "Tarjeta de próximos trenes: título cuando aún no se ha pedido permiso de ubicación."
                ),
                message: LocalizedStringResource(
                    "Verás tu estación más cercana y sus próximos trenes nada más abrir Rail.",
                    comment:
                        "Tarjeta de próximos trenes: explica para qué se pide el permiso de ubicación."
                ),
                icon: .symbol("location.fill", tint: .brandPrimary),
                primary: action(.requestLocation),
                secondary: action(.chooseStation)
            )
        case .permissionDenied:
            CardMessage(
                LocalizedStringResource(
                    "Elige tu estación habitual",
                    comment:
                        "Tarjeta de próximos trenes: título cuando el usuario ha denegado el permiso de ubicación."
                ),
                message: LocalizedStringResource(
                    "No tenemos permiso para usar tu ubicación. Elige la estación que más usas y la tendrás siempre aquí.",
                    comment:
                        "Tarjeta de próximos trenes: mensaje cuando el permiso de ubicación está denegado."
                ),
                icon: .symbol("location.fill", tint: .textTertiary),
                primary: action(.chooseStation),
                secondary: action(.openSettings)
            )
        case .locationUnavailable:
            CardMessage(
                LocalizedStringResource(
                    "No hemos podido ubicarte",
                    comment:
                        "Tarjeta de próximos trenes: título cuando el dispositivo no consigue una ubicación."
                ),
                message: LocalizedStringResource(
                    "Puede pasar bajo tierra o en interiores. Inténtalo otra vez o elige tu estación.",
                    comment:
                        "Tarjeta de próximos trenes: mensaje cuando el dispositivo no consigue una ubicación."
                ),
                icon: .symbol(
                    "exclamationmark.circle.fill",
                    tint: .statusWarning
                ),
                primary: action(.retryLocation),
                secondary: action(.chooseStation)
            )
        case .noStationNearby(let name, let distance):
            CardMessage(
                LocalizedStringResource(
                    "No hay estaciones de Cercanías cerca",
                    comment:
                        "Tarjeta de próximos trenes: título cuando no hay ninguna estación cerca del usuario."
                ),
                message: LocalizedStringResource(
                    "La más próxima, \(name), está a \(distance). Puedes verla en el mapa o elegir tu estación habitual.",
                    comment:
                        "Tarjeta de próximos trenes: el primer valor es el nombre de la estación más próxima y el segundo, la distancia, por ejemplo «38 km»."
                ),
                icon: .symbol("magnifyingglass", tint: .textTertiary),
                primary: action(.showMap),
                secondary: action(.chooseStation)
            )
        }
    }

    private func stationContent(_ station: NextTrainsStation) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                StationHeader(
                    station.name,
                    subtitle: station.proximity.subtitle
                )
                if !dynamicTypeSize.isAccessibilitySize {
                    TrainIllustration()
                        .frame(height: Self.trainHeight)
                        .padding(.top, Self.trainTopInset)
                        .padding(.trailing, -Spacing.md)
                }
            }
            CardSectionHeader(
                LocalizedStringResource(
                    "Próximos trenes",
                    comment:
                        "Tarjeta de próximos trenes: cabecera de la lista de salidas de la estación."
                ),
                systemImage: "clock"
            ) {
                if station.proximity == .saved {
                    Button(
                        LocalizedStringResource(
                            "Cambiar",
                            comment:
                                "Tarjeta de próximos trenes: botón para cambiar la estación habitual guardada."
                        )
                    ) {
                        onAction(.chooseStation)
                    }
                    .buttonStyle(.rail(.borderless))
                    .controlSize(.small)
                }
            }
            DepartureList(station.departures)
        }
    }

    private func action(_ action: NextTrainsCardAction) -> CardMessage.Action {
        CardMessage.Action(title: action.title) { onAction(action) }
    }
}

extension NextTrainsProximity {
    fileprivate var subtitle: LocalizedStringResource {
        switch self {
        case .walking(let minutes):
            LocalizedStringResource(
                "A \(minutes) minutos a pie",
                comment:
                    "Tarjeta de próximos trenes: tiempo andando hasta la estación, por ejemplo «A 15 minutos a pie»."
            )
        case .distance(let distance):
            .distanceAway(distance)
        case .saved:
            LocalizedStringResource(
                "Tu estación habitual",
                comment:
                    "Tarjeta de próximos trenes: subtítulo cuando la estación es la que el usuario ha guardado."
            )
        }
    }
}

extension NextTrainsCardAction {
    fileprivate var title: LocalizedStringResource {
        switch self {
        case .requestLocation:
            LocalizedStringResource(
                "Permitir ubicación",
                comment:
                    "Tarjeta de próximos trenes: botón que pide el permiso de ubicación."
            )
        case .openSettings:
            LocalizedStringResource(
                "Abrir Ajustes",
                comment:
                    "Tarjeta de próximos trenes: botón que abre los ajustes de la app para conceder la ubicación."
            )
        case .retryLocation:
            LocalizedStringResource(
                "Reintentar",
                comment:
                    "Tarjeta de próximos trenes: botón para volver a buscar la ubicación."
            )
        case .chooseStation:
            LocalizedStringResource(
                "Elegir estación",
                comment:
                    "Tarjeta de próximos trenes: botón que abre el selector de estación habitual."
            )
        case .showMap:
            LocalizedStringResource(
                "Ver en el mapa",
                comment:
                    "Tarjeta de próximos trenes: botón que muestra en el mapa la estación más próxima."
            )
        }
    }
}

extension NextTrainsCardState {
    fileprivate static func sampleStation(
        _ proximity: NextTrainsProximity,
        departures: NextTrainsDepartures
    ) -> Self {
        .station(
            NextTrainsStation(
                name: "Estación La Colina",
                proximity: proximity,
                departures: departures
            )
        )
    }

    fileprivate static func sampleDeparture(
        _ id: String,
        to destination: String,
        time: String
    ) -> NextTrainsDeparture {
        NextTrainsDeparture(
            id: id,
            line: "C-1",
            colorHex: "DA291C",
            destination: destination,
            time: time
        )
    }

    fileprivate static let walking = sampleStation(
        .walking(minutes: 15),
        departures: .upcoming([
            sampleDeparture("1", to: "Fuengirola", time: "14:06"),
            sampleDeparture("2", to: "Málaga C. Alameda", time: "14:06"),
        ])
    )

    fileprivate static let distance = sampleStation(
        .distance("1,2 km"),
        departures: .upcoming([
            sampleDeparture("1", to: "Fuengirola", time: "14:06"),
            sampleDeparture("2", to: "Alameda", time: "14:21"),
        ])
    )

    fileprivate static let finished = sampleStation(
        .walking(minutes: 15),
        departures: .finished(firstTomorrow: "05:40")
    )

    fileprivate static let figma: [Self] = [
        walking,
        distance,
        .permissionNeeded,
        .permissionDenied,
        .locationUnavailable,
        .noStationNearby(name: "Álora", distance: "38 km"),
        finished,
    ]

    fileprivate static let extra: [Self] = [
        .locating,
        sampleStation(.walking(minutes: 1), departures: .loading),
        sampleStation(
            .saved,
            departures: .upcoming([
                sampleDeparture("1", to: "Fuengirola", time: "14:06"),
                sampleDeparture("2", to: "Málaga C. Alameda", time: "14:21"),
            ])
        ),
        sampleStation(
            .distance("1,2 km"),
            departures: .finished(firstTomorrow: nil)
        ),
    ]
}

private struct NextTrainsCardSamples: View {
    let states: [NextTrainsCardState]

    var body: some View {
        ScrollView {
            VStack(spacing: ScreenLayout.gutter) {
                ForEach(states, id: \.self) { state in
                    NextTrainsCard(state) { _ in }
                }
            }
            .padding(ScreenLayout.margin)
        }
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    NextTrainsCardSamples(states: NextTrainsCardState.figma)
}

#Preview("Estados extra") {
    NextTrainsCardSamples(states: NextTrainsCardState.extra)
}

#Preview("Modo oscuro") {
    NextTrainsCardSamples(states: [.walking, .permissionNeeded, .finished])
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    NextTrainsCardSamples(states: [.walking, .permissionNeeded])
        .dynamicTypeSize(.accessibility2)
}
