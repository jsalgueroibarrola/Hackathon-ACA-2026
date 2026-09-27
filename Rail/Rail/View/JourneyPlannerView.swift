import SwiftData
import SwiftUI

enum JourneyEndpoint: String, Identifiable {
    case origin
    case destination

    var id: String { rawValue }
}

struct JourneyPlannerView: View {
    @Binding var path: [AppRoute]

    @Environment(LocationViewModel.self) private var location
    @Environment(RecentJourneysViewModel.self) private var recentsModel
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @Query(sort: RecentJourney.order) private var recents: [RecentJourney]
    @State private var originID: String?
    @State private var destinationID: String?
    @State private var selectedDay: Date?
    @State private var picking: JourneyEndpoint?

    private static let heroHeight: CGFloat = 320

    private var calendar: Calendar {
        networks.first?.calendar ?? .current
    }

    private var stationNames: [String: String] {
        Dictionary(stations.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
    }

    private var nearbyOriginID: String? {
        location.nearest(stations, limit: 1)
            .first { $0.distance <= NextTrainsCardStateBuilder.nearbyRadius }?
            .station.id
    }

    private var origin: String? {
        originID ?? (destinationID == nearbyOriginID ? nil : nearbyOriginID)
    }

    private var destination: String? { destinationID }

    private var canSearch: Bool {
        origin != nil && destination != nil && origin != destination
    }

    private func days(today: Date) -> [Date] {
        timetables.first.map {
            StationTimetableBuilder.days(
                from: $0.startDay,
                through: $0.endDay,
                today: today,
                calendar: calendar
            )
        } ?? []
    }

    private func day(in days: [Date]) -> Date? {
        selectedDay.flatMap { days.contains($0) ? $0 : nil } ?? days.first
    }

    var body: some View {
        NavigationStack(path: $path) {
            let now = Date.now
            let names = stationNames
            let days = days(today: now)
            let items = RecentJourneyItemBuilder.items(recents, stationNames: names, now: now)
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    Text(Self.heading)
                        .font(.title2Emphasized)
                        .foregroundStyle(.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    JourneySearchCard(
                        originName: origin.flatMap { names[$0] },
                        destinationName: destination.flatMap { names[$0] },
                        days: days,
                        day: Binding(get: { day(in: days) }, set: { selectedDay = $0 }),
                        today: now,
                        calendar: calendar,
                        canSearch: canSearch
                    ) { action in
                        handle(action, day: day(in: days))
                    }
                    recentSection(items)
                }
                .padding(.horizontal, ScreenLayout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxl)
                .frame(maxWidth: ScreenLayout.maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(alignment: .top) { hero }
            .background(.bgSecondary)
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .appRouteDestinations()
            .sheet(item: $picking) { endpoint in
                StationPickerSheet(
                    selection: Set([endpoint == .origin ? origin : destination].compactMap(\.self))
                ) { stationID in
                    pick(stationID, for: endpoint)
                }
            }
        }
    }

    private var hero: some View {
        LinearGradient(
            colors: [.brandPrimarySubtle, .bgSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: Self.heroHeight)
        .ignoresSafeArea(edges: [.top, .horizontal])
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func recentSection(_ items: [RecentJourneyItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CardSectionHeader(Self.recentTitle, systemImage: "clock") {
                if !items.isEmpty {
                    Button(Self.clearTitle, role: .destructive) {
                        withAnimation(.snappy) {
                            recentsModel.clear()
                        }
                    }
                    .buttonStyle(.rail(.borderless))
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, Spacing.xs)
            VStack(spacing: 0) {
                if items.isEmpty {
                    CardMessage(
                        Self.noRecentsTitle,
                        message: Self.noRecentsMessage,
                        icon: .symbol("magnifyingglass", tint: .textTertiary),
                        prominence: .compact
                    )
                    .padding(Spacing.md)
                } else {
                    ForEach(items) { item in
                        recentRow(item, showsSeparator: item.id != items.last?.id)
                    }
                }
            }
            .background(.bgPrimary, in: .rect(cornerRadius: Radius.md, style: .continuous))
            .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
            .compositingGroup()
            .elevation(.card)
        }
    }

    private func recentRow(_ item: RecentJourneyItem, showsSeparator: Bool) -> some View {
        Button {
            originID = item.originID
            destinationID = item.destinationID
            path.append(.journey(item.query))
        } label: {
            RecentJourneyRow(item, showsSeparator: showsSeparator)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(Self.removeTitle, systemImage: "trash", role: .destructive) {
                withAnimation(.snappy) {
                    recentsModel.remove(originID: item.originID, destinationID: item.destinationID)
                }
            }
        }
    }

    private func handle(_ action: JourneySearchAction, day: Date?) {
        switch action {
        case .pickOrigin:
            picking = .origin
        case .pickDestination:
            picking = .destination
        case .swap:
            (originID, destinationID) = (destination, origin)
        case .search:
            guard canSearch, let origin, let destination else { return }
            path.append(.journey(JourneyQuery(originID: origin, destinationID: destination, day: day)))
        }
    }

    private func pick(_ stationID: String, for endpoint: JourneyEndpoint) {
        switch endpoint {
        case .origin:
            if stationID == destination {
                destinationID = origin
            }
            originID = stationID
        case .destination:
            if stationID == origin {
                originID = destination
            }
            destinationID = stationID
        }
    }

    static let title = LocalizedStringResource(
        "Trayectos",
        comment: "Título de la pestaña y de la pantalla para buscar trenes entre dos estaciones."
    )

    private static let heading = LocalizedStringResource(
        "¿A dónde quieres ir?",
        comment: "Trayectos: título grande encima del buscador de trenes."
    )

    private static let recentTitle = LocalizedStringResource(
        "Búsquedas recientes",
        comment: "Trayectos: cabecera de la lista con los últimos trayectos consultados."
    )

    private static let clearTitle = LocalizedStringResource(
        "Borrar",
        comment: "Trayectos: botón que elimina todas las búsquedas recientes."
    )

    private static let removeTitle = LocalizedStringResource(
        "Eliminar",
        comment: "Trayectos: opción del menú contextual que quita una búsqueda reciente."
    )

    private static let noRecentsTitle = LocalizedStringResource(
        "Sin búsquedas recientes",
        comment: "Trayectos: título cuando todavía no se ha buscado ningún trayecto."
    )

    private static let noRecentsMessage = LocalizedStringResource(
        "Los trayectos que consultes aparecerán aquí para repetirlos con un toque.",
        comment: "Trayectos: explicación de la lista de búsquedas recientes cuando está vacía."
    )
}

#if DEBUG
    private enum RecentJourneysScenario: SampleDataScenario {
        static func populate(_ context: ModelContext) {
            StationTimetableScenario.populate(context)
            context.insertAll([
                RecentJourney(originID: "54413", destinationID: "54100", lastSearchedAt: .now.addingTimeInterval(-900)),
                RecentJourney(originID: "54100", destinationID: "54503", lastSearchedAt: .now.addingTimeInterval(-86_400)),
                RecentJourney(originID: "54406", destinationID: "54404", lastSearchedAt: .now.addingTimeInterval(-4 * 86_400)),
            ])
        }
    }

    private struct JourneyPlannerPreview: View {
        @State private var path: [AppRoute] = []

        var body: some View {
            JourneyPlannerView(path: $path)
        }
    }

    #Preview("Con recientes", traits: .modifier(SampleDataPreview<RecentJourneysScenario>())) {
        JourneyPlannerPreview()
            .environment(LocationViewModel.preview(location: .alameda))
    }

    #Preview("Sin recientes", traits: .stationTimetableSampleData) {
        JourneyPlannerPreview()
            .environment(LocationViewModel.preview(authorization: .denied))
    }

    #Preview("Modo oscuro", traits: .modifier(SampleDataPreview<RecentJourneysScenario>())) {
        JourneyPlannerPreview()
            .environment(LocationViewModel.preview(location: .alameda))
            .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type", traits: .modifier(SampleDataPreview<RecentJourneysScenario>())) {
        JourneyPlannerPreview()
            .environment(LocationViewModel.preview(location: .alameda))
            .dynamicTypeSize(.accessibility2)
    }
#endif
