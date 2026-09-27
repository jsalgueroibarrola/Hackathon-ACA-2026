import SwiftUI

struct MapFeedStatusBadge: View {
    let status: MapFeedStatus

    @ScaledMetric(relativeTo: .caption) private var height: CGFloat = Size.chip

    var body: some View {
        HStack(spacing: Spacing.xs) {
            switch status {
            case .loading:
                ProgressView()
                    .controlSize(.mini)
            case .offline:
                Image(systemName: "wifi.slash")
                    .accessibilityHidden(true)
            }
            Text(title)
                .lineLimit(1)
        }
        .font(.captionEmphasized)
        .foregroundStyle(.glassText)
        .padding(.horizontal, Spacing.md)
        .frame(minHeight: height)
        .glassEffect(.regular, in: .capsule)
        .fixedSize()
        .accessibilityElement(children: .combine)
    }

    private var title: LocalizedStringResource {
        switch status {
        case .loading: Self.loadingTitle
        case .offline: Self.offlineTitle
        }
    }

    private static let loadingTitle = LocalizedStringResource(
        "Cargando trenes",
        comment: "Mapa: aviso en la esquina superior mientras llega por primera vez la posición de los trenes en tiempo real."
    )

    private static let offlineTitle = LocalizedStringResource(
        "Sin conexión",
        comment: "Mapa: aviso en la esquina superior cuando el dispositivo no tiene internet y no se puede actualizar la posición de los trenes."
    )
}

#if DEBUG
    #Preview {
        VStack(spacing: Spacing.md) {
            MapFeedStatusBadge(status: .loading)
            MapFeedStatusBadge(status: .offline)
        }
        .padding(Spacing.xxl)
        .background(.bgSecondary)
    }
#endif
