import SwiftUI

struct RouteDirectionsPanel: View {
    let plan: RoutePlan
    @Binding var mode: TravelMode
    var onOpenInMaps: () -> Void

    @State private var showsSteps = true
    @State private var now: Date = .now

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            modePicker
            summary
            directions
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(in: .rect(cornerRadius: Radius.xl))
        .task {
            while !Task.isCancelled {
                now = .now
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    private var modePicker: some View {
        Picker("Medio de transporte", selection: $mode) {
            ForEach(TravelMode.allCases) { mode in
                Image(systemName: mode.symbolName)
                    .accessibilityLabel(Text(mode.title))
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    @ViewBuilder
    private var summary: some View {
        switch plan {
        case .locating:
            Label("Esperando tu ubicación…", systemImage: "location")
                .font(.subheadline)
                .foregroundStyle(.textSecondary)

        case .calculating:
            HStack(spacing: Spacing.sm) {
                ProgressView()
                Text("Calculando la ruta…")
                    .foregroundStyle(.textSecondary)
            }

        case .directions(let route):
            RouteHeadline(
                time: route.timeLabel,
                distance: route.distance,
                arrival: route.arrival(departingAt: now)
            )

        case .estimate(let estimate):
            VStack(alignment: .leading, spacing: Spacing.sm) {
                RouteHeadline(
                    time: estimate.timeLabel,
                    distance: estimate.distance,
                    arrival: estimate.arrival
                )
                if let departure = estimate.departureLabel {
                    Text("Sale a las \(departure)")
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
                Text(RouteError.unsupportedMode.message)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                Button(action: onOpenInMaps) {
                    Label("Abrir en Mapas", systemImage: "arrow.up.forward.app")
                }
                .buttonStyle(.rail(.bordered))
                .controlSize(.small)
            }

        case .failure(let error):
            Label {
                Text(error.message)
                    .font(.subheadline)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
            .foregroundStyle(.textSecondary)
        }
    }

    @ViewBuilder
    private var directions: some View {
        if let route = plan.route, !route.steps.isEmpty {
            Button {
                withAnimation(.snappy) { showsSteps.toggle() }
            } label: {
                Label(
                    showsSteps ? "Ocultar indicaciones" : "Ver indicaciones",
                    systemImage: showsSteps ? "chevron.down" : "chevron.up"
                )
            }
            .buttonStyle(.rail(.borderless))
            .controlSize(.small)

            if showsSteps {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        ForEach(route.steps) { step in
                            RouteStepRow(step: step)
                        }
                    }
                    .padding(.vertical, Spacing.xxs)
                }
                .frame(maxHeight: 220)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }
}

private struct RouteHeadline: View {
    let time: String
    let distance: Measurement<UnitLength>
    let arrival: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(time)
                .font(.timeDepartureLarge)
            if let arrival {
                Text(
                    "\(distance.distanceLabel) · llegada a las \(arrival.formatted(date: .omitted, time: .shortened))"
                )
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
            } else {
                Text(distance.distanceLabel)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

private struct RouteStepRow: View {
    let step: RouteStep

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: step.symbolName)
                .font(.subheadline)
                .foregroundStyle(.brandPrimary)
                .frame(width: Size.iconMd)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(step.instructions)
                    .font(.subheadline)
                if let notice = step.notice {
                    Text(notice)
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
                if step.distance.value > 0 {
                    Text(step.distance.distanceLabel)
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
    }
}

// MARK: - Previews

private struct PanelBackdrop<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "DCE7D5"), Color(hex: "EFEAE0")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
                .padding(ScreenLayout.margin)
        }
    }
}

extension TravelRoute {
    fileprivate static let sample = TravelRoute(
        mode: .walking,
        name: "Alameda Principal",
        travelTime: .seconds(1440),
        distance: Measurement(value: 1682, unit: .meters),
        coordinates: [],
        steps: [
            RouteStep(
                position: 0,
                instructions: "Camina hacia el sur por Alameda Principal",
                notice: nil,
                distance: Measurement(value: 420, unit: .meters),
                isArrival: false
            ),
            RouteStep(
                position: 1,
                instructions: "Gira a la derecha en Avenida de Andalucía",
                notice: "Obras en la acera",
                distance: Measurement(value: 860, unit: .meters),
                isArrival: false
            ),
            RouteStep(
                position: 2,
                instructions: "Has llegado a tu destino",
                notice: nil,
                distance: Measurement(value: 0, unit: .meters),
                isArrival: true
            ),
        ],
        advisories: [],
        hasTolls: false
    )
}

#Preview("Con indicaciones") {
    @Previewable @State var mode: TravelMode = .walking

    PanelBackdrop {
        RouteDirectionsPanel(
            plan: .directions(.sample),
            mode: $mode,
            onOpenInMaps: {}
        )
    }
}

#Preview("Calculando") {
    @Previewable @State var mode: TravelMode = .cycling

    PanelBackdrop {
        RouteDirectionsPanel(plan: .calculating, mode: $mode, onOpenInMaps: {})
    }
}

#Preview("Transporte público") {
    @Previewable @State var mode: TravelMode = .transit

    PanelBackdrop {
        RouteDirectionsPanel(
            plan: .estimate(
                TravelEstimate(
                    mode: .transit,
                    travelTime: .seconds(900),
                    distance: Measurement(value: 2031, unit: .meters),
                    departure: Date(timeIntervalSince1970: 1_790_000_000),
                    arrival: Date(timeIntervalSince1970: 1_790_000_900)
                )
            ),
            mode: $mode,
            onOpenInMaps: {}
        )
    }
}

#Preview("Sin ruta") {
    @Previewable @State var mode: TravelMode = .automobile

    PanelBackdrop {
        RouteDirectionsPanel(
            plan: .failure(.unavailable),
            mode: $mode,
            onOpenInMaps: {}
        )
    }
}

#Preview("Dynamic Type") {
    @Previewable @State var mode: TravelMode = .walking

    PanelBackdrop {
        RouteDirectionsPanel(
            plan: .directions(.sample),
            mode: $mode,
            onOpenInMaps: {}
        )
    }
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Modo oscuro") {
    @Previewable @State var mode: TravelMode = .walking

    PanelBackdrop {
        RouteDirectionsPanel(
            plan: .directions(.sample),
            mode: $mode,
            onOpenInMaps: {}
        )
    }
    .preferredColorScheme(.dark)
}
