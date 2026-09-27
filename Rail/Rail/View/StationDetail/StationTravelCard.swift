import CoreLocation
import SwiftUI

struct StationTravelCard: View {
    let station: Station

    @Environment(LocationViewModel.self) private var location
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var result: RouteEstimates?
    @State private var attempt = 0

    private var request: RouteEstimateRequest? {
        guard farDistance == nil else { return nil }
        return location.location.map {
            RouteEstimateRequest(
                from: $0,
                to: station,
                modes: TravelMode.allCases,
                attempt: attempt
            )
        }
    }

    private var estimates: [TravelMode: TravelEstimate]? {
        result.flatMap { $0.requestID == request?.id ? $0.values : nil }
    }

    private var farDistance: Measurement<UnitLength>? {
        location.distance(to: station.coordinate).flatMap {
            $0 > Self.maximumDistance ? $0 : nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            CardSectionHeader(Self.title, systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill")
            content
        }
        .cardSurface()
        .loadRouteEstimates(request, into: $result)
    }

    @ViewBuilder
    private var content: some View {
        if location.canRequestAccess {
            CardMessage(
                LocalizedStringResource(
                    "Activa la ubicación",
                    comment: "Detalle de estación: título de «Cómo llegar» cuando aún no se ha pedido permiso de ubicación."
                ),
                message: LocalizedStringResource(
                    "Sabrás cuánto tardas en llegar andando, en bici, en coche o en transporte público.",
                    comment: "Detalle de estación: explica para qué se pide la ubicación en «Cómo llegar»."
                ),
                icon: .symbol("location.fill", tint: .brandPrimary),
                prominence: .compact,
                primary: CardMessage.Action(title: Self.allowLocation, perform: location.requestAccess),
                secondary: openInMaps
            )
        } else if location.isAccessBlocked || location.hasLocationFailed {
            CardMessage(
                LocalizedStringResource(
                    "Mapas te lleva hasta aquí",
                    comment: "Detalle de estación: título de «Cómo llegar» cuando no hay ubicación del dispositivo."
                ),
                message: LocalizedStringResource(
                    "Sin tu ubicación no podemos estimar los tiempos, pero Mapas puede guiarte desde donde estés.",
                    comment: "Detalle de estación: mensaje de «Cómo llegar» cuando no hay permiso o no se consigue la ubicación."
                ),
                icon: .symbol("location.slash.fill", tint: .textTertiary),
                prominence: .compact,
                primary: openInMaps
            )
        } else if let farDistance {
            CardMessage(
                LocalizedStringResource(
                    "Estás lejos de la estación",
                    comment: "Detalle de estación: título de «Cómo llegar» cuando la ubicación del usuario está demasiado lejos para calcular tiempos."
                ),
                message: LocalizedStringResource(
                    "Estás a \(farDistance.distanceLabel) en línea recta. Cuando estés más cerca te diremos cuánto tardas; mientras, Mapas puede guiarte.",
                    comment: "Detalle de estación: mensaje de «Cómo llegar» cuando el usuario está lejos. El argumento es la distancia en línea recta hasta la estación."
                ),
                icon: .symbol("location.magnifyingglass", tint: .textTertiary),
                prominence: .compact,
                primary: openInMaps
            )
        } else if let estimates {
            if estimates.isEmpty {
                CardMessage(
                    LocalizedStringResource(
                        "No hemos podido calcular los tiempos",
                        comment: "Detalle de estación: título de «Cómo llegar» cuando Mapas no devuelve ningún tiempo de viaje."
                    ),
                    message: LocalizedStringResource(
                        "Puede ser la conexión. Inténtalo otra vez o abre la ruta directamente en Mapas.",
                        comment: "Detalle de estación: mensaje de «Cómo llegar» cuando falla el cálculo de tiempos."
                    ),
                    icon: .symbol("exclamationmark.circle.fill", tint: .statusWarning),
                    prominence: .compact,
                    primary: openInMaps,
                    secondary: CardMessage.Action(title: Self.retry) { attempt += 1 }
                )
            } else {
                tiles(estimates)
            }
        } else {
            tiles([:])
                .redacted(reason: .placeholder)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(Self.calculating))
        }
    }

    private func tiles(_ estimates: [TravelMode: TravelEstimate]) -> some View {
        let columns = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        let modes = TravelMode.allCases
        let rows = stride(from: 0, to: modes.count, by: columns).map {
            Array(modes[$0..<min($0 + columns, modes.count)])
        }
        return Grid(horizontalSpacing: Spacing.sm, verticalSpacing: Spacing.sm) {
            ForEach(rows, id: \.self) { row in
                GridRow {
                    ForEach(row) { mode in
                        tile(mode, estimate: estimates[mode])
                    }
                }
            }
        }
    }

    private func tile(_ mode: TravelMode, estimate: TravelEstimate?) -> some View {
        Button {
            station.openDirections(mode)
        } label: {
            TravelModeTile(
                mode,
                time: estimate?.timeLabel,
                detail: estimate?.distance.distanceLabel
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(Self.tileHint))
    }

    private var openInMaps: CardMessage.Action {
        CardMessage.Action(title: Self.openInMapsTitle) { station.openDirections() }
    }

    private static let maximumDistance = Measurement<UnitLength>(value: 100, unit: .kilometers)

    private static let title = LocalizedStringResource(
        "Cómo llegar",
        comment: "Detalle de estación: cabecera de la tarjeta con los tiempos de viaje hasta la estación."
    )

    private static let allowLocation = LocalizedStringResource(
        "Permitir ubicación",
        comment: "Detalle de estación: botón de «Cómo llegar» que pide el permiso de ubicación."
    )

    private static let openInMapsTitle = LocalizedStringResource(
        "Abrir en Mapas",
        comment: "Detalle de estación: botón que abre la ruta hasta la estación en Apple Maps."
    )

    private static let retry = LocalizedStringResource(
        "Reintentar",
        comment: "Detalle de estación: botón para volver a calcular los tiempos de viaje."
    )

    private static let calculating = LocalizedStringResource(
        "Calculando tiempos…",
        comment: "Detalle de estación: VoiceOver mientras se calculan los tiempos de viaje."
    )

    private static let tileHint = LocalizedStringResource(
        "Abre la ruta en Mapas",
        comment: "Detalle de estación: pista de VoiceOver de cada medio de transporte en «Cómo llegar»."
    )
}
