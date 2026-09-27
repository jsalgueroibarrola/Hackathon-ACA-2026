import SwiftUI

struct NearbyNoticeCard: View {
    private let notice: NearbyCarouselNotice
    private let lineID: String?
    private let onAction: (NearbyCarouselAction) -> Void

    init(
        _ notice: NearbyCarouselNotice,
        lineID: String?,
        onAction: @escaping (NearbyCarouselAction) -> Void
    ) {
        self.notice = notice
        self.lineID = lineID
        self.onAction = onAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label {
                Text(notice.title)
            } icon: {
                Image(systemName: notice.symbolName)
            }
            .font(.headline)
            .foregroundStyle(.glassText)
            .lineLimit(2, reservesSpace: true)
            HStack {
                actionView
                Spacer(minLength: 0)
            }
            .frame(minHeight: Size.buttonSm)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .lineLimit(1, reservesSpace: true)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.xl))
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var actionView: some View {
        if let action = notice.action {
            Button(action.title) {
                onAction(action)
            }
            .buttonStyle(.rail(.borderless))
            .controlSize(.small)
        } else {
            ProgressView()
                .controlSize(.small)
        }
    }

    private var message: LocalizedStringResource {
        lineID.map {
            LocalizedStringResource(
                "Desliza para explorar la línea \($0)",
                comment: "Mapa, carrusel de estaciones: mensaje de la primera tarjeta cuando no hay estaciones cercanas; el carrusel muestra las estaciones de esa línea, por ejemplo «Desliza para explorar la línea C1»."
            )
        } ?? Self.exploreNetwork
    }

    private static let exploreNetwork = LocalizedStringResource(
        "Mueve el mapa para explorar la red",
        comment: "Mapa, carrusel de estaciones: mensaje de la primera tarjeta cuando no hay estaciones cercanas ni líneas que proponer."
    )
}

extension NearbyCarouselNotice {
    fileprivate var title: LocalizedStringResource {
        switch self {
        case .permissionNeeded:
            LocalizedStringResource(
                "Estaciones cerca de ti",
                comment: "Mapa, carrusel de estaciones: título de la primera tarjeta cuando aún no se ha pedido el permiso de ubicación."
            )
        case .permissionDenied:
            LocalizedStringResource(
                "Ubicación desactivada",
                comment: "Mapa, carrusel de estaciones: título de la primera tarjeta cuando el permiso de ubicación está denegado."
            )
        case .locating:
            LocalizedStringResource(
                "Buscando tu ubicación…",
                comment: "Mapa, carrusel de estaciones: título de la primera tarjeta mientras se obtiene la ubicación."
            )
        case .locationUnavailable:
            LocalizedStringResource(
                "No hemos podido ubicarte",
                comment: "Mapa, carrusel de estaciones: título de la primera tarjeta cuando el dispositivo no consigue una ubicación."
            )
        case .farFromNetwork:
            LocalizedStringResource(
                "Estás lejos de Cercanías Málaga",
                comment: "Mapa, carrusel de estaciones: título de la primera tarjeta cuando ninguna estación está a menos de 10 km."
            )
        }
    }

    fileprivate var symbolName: String {
        switch self {
        case .permissionNeeded: "location.circle"
        case .permissionDenied: "location.slash"
        case .locating: "location.magnifyingglass"
        case .locationUnavailable: "location.slash"
        case .farFromNetwork: "map"
        }
    }
}

extension NearbyCarouselAction {
    fileprivate var title: LocalizedStringResource {
        switch self {
        case .requestLocation:
            LocalizedStringResource(
                "Permitir ubicación",
                comment: "Mapa, carrusel de estaciones: botón que pide el permiso de ubicación para mostrar las estaciones cercanas."
            )
        case .openSettings:
            LocalizedStringResource(
                "Abrir Ajustes",
                comment: "Mapa, carrusel de estaciones: botón que abre los ajustes de la app para conceder la ubicación."
            )
        case .retryLocation:
            LocalizedStringResource(
                "Reintentar",
                comment: "Mapa, carrusel de estaciones: botón que vuelve a intentar obtener la ubicación."
            )
        case .showNetwork:
            LocalizedStringResource(
                "Ver toda la red",
                comment: "Mapa, carrusel de estaciones: botón que aleja la cámara para mostrar toda la red cuando el usuario está lejos."
            )
        }
    }
}

#if DEBUG
private struct NearbyNoticeCardSamples: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                NearbyNoticeCard(.permissionNeeded, lineID: "C1") { _ in }
                NearbyNoticeCard(.permissionDenied, lineID: "C1") { _ in }
                NearbyNoticeCard(.locating, lineID: "C1") { _ in }
                NearbyNoticeCard(.locationUnavailable, lineID: "C1") { _ in }
                NearbyNoticeCard(.farFromNetwork, lineID: "C1") { _ in }
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

#Preview("Avisos") {
    NearbyNoticeCardSamples()
}

#Preview("Modo oscuro") {
    NearbyNoticeCardSamples()
        .preferredColorScheme(.dark)
}
#endif
