import CoreLocation
import SwiftUI

struct TravelEstimatesSection: View {
    let destination: CLLocationCoordinate2D
    @Binding var routeMode: TravelMode?

    @Environment(LocationViewModel.self) private var location
    @Environment(\.routeEstimates) private var routeEstimates

    @State private var estimates: [TravelMode: TravelEstimate] = [:]
    @State private var isLoading = false

    private struct Request: Equatable {
        let origin: LocationCell?
        let destination: LocationCell
    }

    private var request: Request {
        Request(origin: location.location?.cell, destination: destination.cell)
    }

    var body: some View {
        Section("Cómo llegar") {
            content
        }
        .task(id: request) {
            await load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if location.canRequestAccess || location.isAccessBlocked {
            LocationAccessPrompt(
                message:
                    "Activa la ubicación para saber cuánto tardas en llegar andando, en bici, en coche o en transporte público."
            )
        } else if estimates.isEmpty {
            if isLoading || location.isLocating {
                HStack(spacing: Spacing.sm) {
                    ProgressView()
                    Text("Calculando tiempos…")
                        .foregroundStyle(.textSecondary)
                }
            } else {
                Text("No se han podido calcular los tiempos de viaje")
                    .foregroundStyle(.textSecondary)
            }
        } else {
            ForEach(TravelMode.allCases) { mode in
                Button {
                    routeMode = mode
                } label: {
                    TravelEstimateRow(mode: mode, estimate: estimates[mode])
                }
                .buttonStyle(.plain)
                .accessibilityHint("Muestra la ruta hasta la estación")
            }
        }
    }

    private func load() async {
        guard let origin = location.location else {
            estimates = [:]
            return
        }

        isLoading = true
        let result = await routeEstimates.estimates(
            from: origin.coordinate,
            to: destination,
            modes: TravelMode.allCases
        )
        isLoading = false

        guard !Task.isCancelled else { return }
        estimates = result
    }
}

private struct TravelEstimateRow: View {
    let mode: TravelMode
    let estimate: TravelEstimate?

    var body: some View {
        LabeledContent {
            HStack(spacing: Spacing.sm) {
                if let estimate {
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text(estimate.timeLabel)
                            .font(.bodyEmphasized)
                            .monospacedDigit()
                        Text(estimate.distance.distanceLabel)
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                    }
                } else {
                    Text("No disponible")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.captionEmphasized)
                    .foregroundStyle(.textSecondary)
            }
        } label: {
            Label {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(mode.title)
                    if mode == .transit, let departure = estimate?.departureLabel
                    {
                        Text("Sale a las \(departure)")
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                    }
                }
            } icon: {
                Image(systemName: mode.symbolName)
                    .foregroundStyle(.brandPrimary)
            }
        }
    }
}

// MARK: - Previews

extension CLLocationCoordinate2D {
    fileprivate static let mariaZambrano = CLLocationCoordinate2D(
        latitude: 36.7119,
        longitude: -4.4315
    )
}

#Preview("Con tiempos") {
    @Previewable @State var routeMode: TravelMode?

    List {
        TravelEstimatesSection(
            destination: .mariaZambrano,
            routeMode: $routeMode
        )
    }
    .environment(LocationViewModel.preview())
    .environment(\.routeEstimates, PreviewRouteService())
}

#Preview("Con transporte público") {
    @Previewable @State var routeMode: TravelMode?

    List {
        TravelEstimatesSection(
            destination: .mariaZambrano,
            routeMode: $routeMode
        )
    }
    .environment(LocationViewModel.preview())
    .environment(
        \.routeEstimates,
        PreviewRouteService(
            values: [
                .walking: TravelEstimate(
                    mode: .walking,
                    travelTime: .seconds(1440),
                    distance: Measurement(value: 1682, unit: .meters),
                    departure: nil,
                    arrival: nil
                ),
                .transit: TravelEstimate(
                    mode: .transit,
                    travelTime: .seconds(900),
                    distance: Measurement(value: 2031, unit: .meters),
                    departure: Date(timeIntervalSince1970: 1_790_000_000),
                    arrival: Date(timeIntervalSince1970: 1_790_000_900)
                ),
            ]
        )
    )
}

#Preview("Sin resultados") {
    @Previewable @State var routeMode: TravelMode?

    List {
        TravelEstimatesSection(
            destination: .mariaZambrano,
            routeMode: $routeMode
        )
    }
    .environment(LocationViewModel.preview())
    .environment(\.routeEstimates, PreviewRouteService(values: [:]))
}

#Preview("Sin permiso") {
    @Previewable @State var routeMode: TravelMode?

    List {
        TravelEstimatesSection(
            destination: .mariaZambrano,
            routeMode: $routeMode
        )
    }
    .environment(LocationViewModel.preview(authorization: .notDetermined))
    .environment(\.routeEstimates, PreviewRouteService())
}

#Preview("Dynamic Type") {
    @Previewable @State var routeMode: TravelMode?

    List {
        TravelEstimatesSection(
            destination: .mariaZambrano,
            routeMode: $routeMode
        )
    }
    .environment(LocationViewModel.preview())
    .environment(\.routeEstimates, PreviewRouteService())
    .environment(\.dynamicTypeSize, .accessibility2)
}
