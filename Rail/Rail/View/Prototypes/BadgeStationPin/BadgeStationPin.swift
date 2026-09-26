import Foundation
import SwiftUI

struct BadgedStationPin: View {
    let pin: StationPin
    let zoom: ZoomBucket
    var isSelected: Bool = false

    private static let chipIconSize: CGFloat = 10
    private static let chipInsets = EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 6)

    private var dotSize: CGFloat {
        zoom.dotSize * (isSelected ? 1.35 : 1)
    }

    private var showsChip: Bool {
        guard zoom.showsChip else { return false }
        if pin.isAccessible { return true }
        return zoom.showsConnections
            && (!pin.connections.isEmpty || pin.hasElevator)
    }

    var body: some View {
        StationDot(color: pin.color, size: dotSize)
            .background(alignment: .leading) {
                if showsChip { chip }
            }
            .overlay(alignment: .topTrailing) {
                if !showsChip, zoom.showsAccessibility, pin.isAccessible {
                    BadgeIcon(
                        systemName: StationAccessibilitySymbol.reducedMobility,
                        tint: StationPin.accessibleTint,
                        diameter: dotSize * 0.62
                    )
                    .offset(x: dotSize * 0.3, y: -dotSize * 0.3)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay {
                if isSelected, !showsChip {
                    Circle()
                        .strokeBorder(.tint, lineWidth: Border.thick)
                        .padding(-Spacing.xs)
                }
            }
            .animation(.snappy(duration: 0.24), value: zoom)
            .animation(.snappy(duration: 0.24), value: isSelected)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(pin.name)
            .accessibilityValue(accessibilityValue)
    }

    private var chip: some View {
        HStack(spacing: Spacing.xs) {
            Color.clear
                .frame(width: dotSize, height: dotSize)

            if pin.isAccessible {
                Image(systemName: StationAccessibilitySymbol.reducedMobility)
                    .foregroundStyle(StationPin.accessibleTint)
            }

            if zoom.showsConnections {
                Group {
                    if pin.hasElevator {
                        Image(systemName: StationAccessibilitySymbol.elevator)
                            .foregroundStyle(StationPin.elevatorTint)
                    }
                    ForEach(pin.connections, id: \.self) { connection in
                        Image(systemName: connection.symbolName)
                            .foregroundStyle(connection.tint)
                    }
                }
                .transition(
                    .scale(scale: 0.4, anchor: .leading).combined(with: .opacity)
                )
            }
        }
        .font(.system(size: Self.chipIconSize, weight: .semibold))
        .padding(Self.chipInsets)
        .background(.background, in: .capsule)
        .overlay {
            if isSelected {
                Capsule().strokeBorder(.tint, lineWidth: Border.thick)
            } else {
                Capsule().strokeBorder(.borderSubtle, lineWidth: Border.hairline)
            }
        }
        .shadow(color: .black.opacity(0.22), radius: 2, y: 1)
        .fixedSize()
        .offset(x: -Self.chipInsets.leading)
        .transition(
            .scale(scale: 0.3, anchor: .leading).combined(with: .opacity)
        )
    }

    private var accessibilityValue: String {
        [
            pin.lineIDs.isEmpty
                ? nil
                : String(
                    localized: "Líneas \(pin.lineIDs.formatted(.list(type: .and)))",
                    comment: "VoiceOver, pin de estación en el mapa: líneas que paran en ella, por ejemplo «Líneas C1 y C2»."
                ),
            pin.isAccessible
                ? String(
                    localized: "Accesible",
                    comment: "VoiceOver, pin de estación en el mapa: la estación es accesible para movilidad reducida."
                )
                : nil,
            pin.connections.isEmpty
                ? nil
                : String(
                    localized: "Conexiones: \(pin.connections.map { String(localized: $0.displayName) }.formatted(.list(type: .and)))",
                    comment: "VoiceOver, pin de estación en el mapa: otros transportes que conectan con ella, por ejemplo «Conexiones: Metro y Autobús urbano»."
                ),
        ]
        .compactMap(\.self)
        .joined(separator: ". ")
    }
}

#if DEBUG
extension StationPin {
    fileprivate static let plain = StationPin(
        id: "portada-alta",
        name: "Portada Alta",
        latitude: 36.7185,
        longitude: -4.4620,
        lineIDs: ["L1"],
        colorHexes: ["E1251B"]
    )

    fileprivate static let accessible = StationPin(
        id: "el-perchel",
        name: "El Perchel",
        latitude: 36.7139,
        longitude: -4.4322,
        isAccessible: true,
        lineIDs: ["L1"],
        colorHexes: ["E1251B"]
    )

    /// Intercambiador: el punto va en el color fijo de ``StationPin/interchangeColor``.
    fileprivate static let interchange = StationPin(
        id: "guadalmedina",
        name: "Guadalmedina",
        latitude: 36.7203,
        longitude: -4.4291,
        isAccessible: true,
        hasElevator: true,
        connections: [.urbanBus],
        lineIDs: ["L1", "L2"],
        colorHexes: ["E1251B", "5C2D91"]
    )

    /// Caso más cargado: varias líneas y toda la fila de conexiones.
    fileprivate static let hub = StationPin(
        id: "maria-zambrano",
        name: "María Zambrano",
        latitude: 36.7118,
        longitude: -4.4318,
        isAccessible: true,
        hasElevator: true,
        connections: [.ave, .regional, .busStation, .interurbanBus, .airport],
        lineIDs: ["L1", "L2"],
        colorHexes: ["E1251B", "5C2D91"]
    )
}

private struct PinRow: View {
    let title: String
    let pin: StationPin
    let zoom: ZoomBucket
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)

            BadgedStationPin(pin: pin, zoom: zoom, isSelected: isSelected)
                .frame(width: 200, alignment: .leading)
        }
    }
}

#Preview("Estados") {
    VStack(alignment: .leading, spacing: 28) {
        PinRow(title: "Simple", pin: .plain, zoom: .detail)
        PinRow(title: "Accesible", pin: .accessible, zoom: .detail)
        PinRow(title: "Intercambiador", pin: .interchange, zoom: .detail)
        PinRow(title: "Con conexiones", pin: .hub, zoom: .detail)
    }
    .padding(32)
}

#Preview("Seleccionado") {
    VStack(alignment: .leading, spacing: 28) {
        PinRow(title: "Simple", pin: .plain, zoom: .detail, isSelected: true)
        PinRow(
            title: "Accesible",
            pin: .accessible,
            zoom: .detail,
            isSelected: true
        )
        PinRow(
            title: "Con conexiones",
            pin: .hub,
            zoom: .detail,
            isSelected: true
        )
        PinRow(
            title: "Punto, sin cápsula",
            pin: .plain,
            zoom: .region,
            isSelected: true
        )
    }
    .padding(32)
}

/// Cómo degrada el mismo pin al alejar la cámara: conexiones → cápsula →
/// insignia suelta → punto pelado.
#Preview("Zoom") {
    VStack(alignment: .leading, spacing: 28) {
        ForEach(ZoomBucket.allCases.reversed(), id: \.self) { zoom in
            PinRow(title: "\(zoom)", pin: .hub, zoom: zoom)
        }
    }
    .padding(32)
}

#Preview("Sobre el mapa") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "DCE7D5"), Color(hex: "EFEAE0")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 32) {
            BadgedStationPin(pin: .accessible, zoom: .detail)
            BadgedStationPin(pin: .hub, zoom: .detail, isSelected: true)
            BadgedStationPin(pin: .interchange, zoom: .street)
            BadgedStationPin(pin: .plain, zoom: .overview)
        }
    }
}

#Preview("Modo oscuro") {
    VStack(alignment: .leading, spacing: 28) {
        PinRow(title: "Simple", pin: .plain, zoom: .detail)
        PinRow(title: "Intercambiador", pin: .interchange, zoom: .detail)
        PinRow(
            title: "Con conexiones",
            pin: .hub,
            zoom: .detail,
            isSelected: true
        )
    }
    .padding(32)
    .preferredColorScheme(.dark)
}
#endif
