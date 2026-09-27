import SwiftUI

enum JourneySearchAction {
    case pickOrigin
    case pickDestination
    case swap
    case search
}

struct JourneySearchCard: View {
    private let originName: String?
    private let destinationName: String?
    private let days: [Date]
    @Binding private var day: Date?
    private let today: Date
    private let calendar: Calendar
    private let canSearch: Bool
    private let onAction: (JourneySearchAction) -> Void

    @State private var swapTurns = 0

    init(
        originName: String?,
        destinationName: String?,
        days: [Date],
        day: Binding<Date?>,
        today: Date,
        calendar: Calendar,
        canSearch: Bool,
        onAction: @escaping (JourneySearchAction) -> Void
    ) {
        self.originName = originName
        self.destinationName = destinationName
        self.days = days
        _day = day
        self.today = today
        self.calendar = calendar
        self.canSearch = canSearch
        self.onAction = onAction
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            JourneyStationField(Self.originTitle, stationName: originName) {
                onAction(.pickOrigin)
            }
            swapDivider
            JourneyStationField(Self.destinationTitle, stationName: destinationName) {
                onAction(.pickDestination)
            }
            separator
                .padding(.top, Spacing.xs)
            dayMenu
            searchButton
        }
        .cardSurface()
        .compositingGroup()
        .elevation(.card)
    }

    private var separator: some View {
        Rectangle()
            .fill(.interactiveSeparator)
            .frame(height: Border.hairline)
    }

    private var swapDivider: some View {
        HStack(spacing: Spacing.md) {
            separator
            Button(Self.swapTitle, systemImage: "arrow.up.arrow.down") {
                withAnimation(.snappy) {
                    swapTurns += 1
                }
                onAction(.swap)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.rail(.bordered))
            .rotationEffect(.degrees(Double(swapTurns) * 180))
            .disabled(originName == nil && destinationName == nil)
            separator
        }
    }

    @ViewBuilder
    private var dayMenu: some View {
        if days.isEmpty {
            Text(Self.noDays)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        } else {
            ServiceDayMenu(days: days, selection: $day, today: today, calendar: calendar)
                .menuStyle(.button)
                .buttonStyle(.rail(.bordered))
        }
    }

    private var searchButton: some View {
        Button {
            onAction(.search)
        } label: {
            HStack(spacing: Spacing.sm) {
                Text(Self.searchTitle)
                Image(systemName: "arrow.right")
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.rail(.prominent))
        .controlSize(.large)
        .disabled(!canSearch || days.isEmpty)
    }

    static let originTitle = LocalizedStringResource(
        "Origen",
        comment: "Trayectos: etiqueta del campo con la estación de salida."
    )

    static let destinationTitle = LocalizedStringResource(
        "Destino",
        comment: "Trayectos: etiqueta del campo con la estación de llegada."
    )

    static let swapTitle = LocalizedStringResource(
        "Invertir sentido",
        comment: "Trayectos: botón que intercambia la estación de origen y la de destino."
    )

    private static let searchTitle = LocalizedStringResource(
        "Buscar trenes",
        comment: "Trayectos: botón principal que busca los trenes entre las dos estaciones elegidas."
    )

    private static let noDays = LocalizedStringResource(
        "Aún no hay horarios descargados.",
        comment: "Trayectos: aviso en lugar del selector de día cuando no hay ningún día con horario."
    )
}

#if DEBUG
private struct JourneySearchCardSample: View {
    @State private var day: Date? = Calendar.current.startOfDay(for: .now)
    let originName: String?
    let destinationName: String?

    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        JourneySearchCard(
            originName: originName,
            destinationName: destinationName,
            days: (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) },
            day: $day,
            today: today,
            calendar: calendar,
            canSearch: originName != nil && destinationName != nil
        ) { _ in }
        .padding(ScreenLayout.margin)
        .frame(maxHeight: .infinity)
        .background(.bgSecondary)
    }
}

#Preview("Completo") {
    JourneySearchCardSample(originName: "Málaga-Centro Alameda", destinationName: "Fuengirola")
}

#Preview("Vacío") {
    JourneySearchCardSample(originName: nil, destinationName: nil)
}

#Preview("Modo oscuro") {
    JourneySearchCardSample(originName: "Málaga-Centro Alameda", destinationName: "Fuengirola")
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    JourneySearchCardSample(originName: "Benalmádena-Arroyo de la Miel", destinationName: "Álora")
        .dynamicTypeSize(.accessibility2)
}
#endif
