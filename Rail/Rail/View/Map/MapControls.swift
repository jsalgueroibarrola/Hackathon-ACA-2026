import MapKit
import SwiftUI

struct MapControls: View {
    @Binding var camera: MapCameraPosition
    let onShowNetwork: () -> Void

    @Environment(LocationViewModel.self) private var location
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .title3) private var side = Size.glassControl

    var body: some View {
        VStack(spacing: 0) {
            control(Self.locationTitle, systemImage: locationSymbol, action: locate)
            control(Self.networkTitle, systemImage: "arrow.up.left.and.arrow.down.right", action: onShowNetwork)
        }
        .font(.title3)
        .foregroundStyle(.glassText)
        .glassEffect(.regular.interactive(), in: .capsule)
    }

    private func control(
        _ title: LocalizedStringResource,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .frame(width: side, height: side)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var locationSymbol: String {
        switch (location.isAccessBlocked, camera.followsUserLocation) {
        case (true, _): "location.slash"
        case (false, true): "location.fill"
        case (false, false): "location"
        }
    }

    private func locate() {
        if location.canRequestAccess {
            location.requestAccess()
        } else if location.isAccessBlocked, let settings = URL.appSettings {
            openURL(settings)
        } else {
            withAnimation(MapSheetMotion.camera) {
                camera = .userLocation(fallback: camera)
            }
        }
    }

    private static let locationTitle = LocalizedStringResource(
        "Mi ubicación",
        comment:
            "Mapa: botón flotante que centra el mapa en el usuario, o pide el permiso de ubicación si no lo hay."
    )

    private static let networkTitle = LocalizedStringResource(
        "Ver toda la red",
        comment:
            "Mapa: botón flotante que aleja la cámara para mostrar toda la red de Cercanías."
    )
}

#if DEBUG
    private struct MapControlsSamples: View {
        @State private var camera: MapCameraPosition = .automatic

        var body: some View {
            MapControls(camera: $camera, onShowNetwork: {})
                .padding(ScreenLayout.margin)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .background(
                    LinearGradient(
                        colors: [.green.opacity(0.4), .blue.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    #Preview("Cápsula") {
        MapControlsSamples()
            .environment(LocationViewModel.preview())
    }

    #Preview("Cápsula oscura") {
        MapControlsSamples()
            .environment(LocationViewModel.preview())
            .preferredColorScheme(.dark)
    }
#endif
