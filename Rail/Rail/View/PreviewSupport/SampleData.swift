#if DEBUG
import SwiftData
import SwiftUI
import Translation

enum SampleData {
    static let favoriteStationIDs = [
        "54413", "54100", "54406", "54404", "54407", "54503", "54408", "54405",
    ]

    static func stations() -> [Station] {
        [
            Station(
                id: "54413",
                name: "Málaga-Centro Alameda",
                latitude: 36.7170,
                longitude: -4.4250,
                isAccessible: true,
                hasElevator: true,
                connections: [.metro, .urbanBus]
            ),
            Station(
                id: "54404",
                name: "Málaga María Zambrano",
                latitude: 36.7119,
                longitude: -4.4315,
                isAccessible: true,
                hasElevator: true,
                connections: [.ave, .metro, .busStation, .urbanBus]
            ),
            Station(
                id: "54405",
                name: "Victoria Kent",
                latitude: 36.7030,
                longitude: -4.4430
            ),
            Station(
                id: "54406",
                name: "Aeropuerto",
                latitude: 36.6800,
                longitude: -4.4940,
                isAccessible: true,
                connections: [.airport]
            ),
            Station(
                id: "54407",
                name: "Torremolinos",
                latitude: 36.6219,
                longitude: -4.4999,
                connections: [.urbanBus]
            ),
            Station(
                id: "54408",
                name: "Benalmádena-Arroyo de la Miel",
                latitude: 36.6000,
                longitude: -4.5320
            ),
            Station(
                id: "54100",
                name: "Fuengirola",
                latitude: 36.5397,
                longitude: -4.6262,
                isAccessible: true,
                connections: [.interurbanBus, .urbanBus]
            ),
            Station(
                id: "54501",
                name: "Campanillas",
                latitude: 36.7270,
                longitude: -4.5530
            ),
            Station(
                id: "54502",
                name: "Cártama",
                latitude: 36.7300,
                longitude: -4.6320
            ),
            Station(
                id: "54503",
                name: "Álora",
                latitude: 36.8230,
                longitude: -4.7010,
                connections: [.regional]
            ),
        ]
    }

    static func insertNetwork(into context: ModelContext) {
        let network = TransitNetwork(
            id: "malaga",
            name: "Cercanías Málaga",
            timeZoneIdentifier: "Europe/Madrid",
            version: "2026-09-20",
            lastFetchedAt: .now
        )
        context.insert(network)

        let stations = stations()
        stations.forEach { $0.network = network }
        context.insertAll(stations)

        let stationsByID = Dictionary(
            stations.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        let lines = LineSample.all.map { sample in
            let line = Line(
                id: sample.id,
                name: sample.name,
                colorHex: sample.colorHex,
                shape: sample.shape
            )
            line.network = network
            return line
        }
        context.insertAll(lines)

        let stops = zip(lines, LineSample.all).flatMap { line, sample in
            sample.stationIDs.enumerated().map { sequence, stationID in
                let stop = LineStop(
                    lineID: line.id,
                    stationID: stationID,
                    sequence: sequence
                )
                stop.line = line
                stop.station = stationsByID[stationID]
                return stop
            }
        }
        context.insertAll(stops)
    }
}

private struct LineSample {
    let id: String
    let name: String
    let colorHex: String
    let shape: String
    let stationIDs: [String]

    static let all = [
        LineSample(
            id: "C1",
            name: "Málaga-Centro Alameda – Fuengirola",
            colorHex: "DA291C",
            shape: "ghb_Ffg_Zz^rg@rv@zfAvnCv}HbjJzc@zgCrgEzwJvkQ",
            stationIDs: ["54413", "54404", "54405", "54406", "54407", "54408", "54100"]
        ),
        LineSample(
            id: "C2",
            name: "Málaga-Centro Alameda – Álora",
            colorHex: "0057A8",
            shape: "ghb_Ffg_Zz^rg@rv@zfA_uCnnTwQvlNgdQfnL",
            stationIDs: ["54413", "54404", "54405", "54501", "54502", "54503"]
        ),
    ]
}

extension SavedLocation {
    static let fuengirola = SavedLocation(
        stationID: "54100",
        latitude: 36.5397,
        longitude: -4.6262
    )
}

extension UserLocation {
    static let madrid = UserLocation(
        latitude: 40.4168,
        longitude: -3.7038,
        horizontalAccuracy: 12,
        timestamp: .distantPast
    )
}

protocol SampleDataScenario {
    static func populate(_ context: ModelContext)
}

enum NetworkScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {}
}

enum FavoriteStationsScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        context.insertAll(
            SampleData.favoriteStationIDs.enumerated().map {
                FavoriteStation(stationID: $1, sortOrder: $0)
            }
        )
    }
}

enum StationTimetableScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        FavoriteStationsScenario.populate(context)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Madrid") ?? .gmt
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let end = calendar.date(byAdding: .day, value: 6, to: today) ?? today
        let timetable = Timetable(
            networkID: "malaga",
            version: "preview",
            startDay: start,
            endDay: end,
            lastFetchedAt: .now
        )
        context.insert(timetable)
        let trips = LineSample.all.flatMap { line in
            TripDirection.allCases.flatMap { direction in
                stride(from: 340, through: 1460, by: 20).map { first in
                    let trip = Trip(
                        lineID: line.id,
                        direction: direction,
                        train: "\(line.id == "C1" ? 23 : 36)\(first)",
                        serviceDays: "11111111",
                        times: line.stationIDs.indices.map { first + $0 * 4 }
                    )
                    trip.timetable = timetable
                    return trip
                }
            }
        }
        context.insertAll(trips)
    }
}

enum SavedStationScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        context.insert(SavedStation(.fuengirola))
    }
}

enum ServiceAlertsScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        let feed = ServiceAlertFeed(
            etag: nil,
            feedTimestamp: .now,
            fetchedAt: .now,
            expiresAt: .now.addingTimeInterval(3_600),
            isStale: false
        )
        context.insert(feed)
        let alerts = SampleData.alerts()
        alerts.forEach { $0.feed = feed }
        context.insertAll(alerts)
    }
}

enum EmptyServiceAlertsScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        context.insert(
            ServiceAlertFeed(
                etag: nil,
                feedTimestamp: .now,
                fetchedAt: .now,
                expiresAt: .now.addingTimeInterval(3_600),
                isStale: false
            )
        )
    }
}

enum LiveTrainsScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        let feed = RealtimeFeed(
            etag: nil,
            feedTimestamp: .now,
            isPartial: false,
            fetchedAt: .now,
            expiresAt: .now.addingTimeInterval(3_600),
            isStale: false
        )
        context.insert(feed)
        let trains = SampleData.liveTrains()
        trains.forEach { $0.feed = feed }
        context.insertAll(trains)
    }
}

extension SampleData {
    static func liveTrains(now: Date = .now) -> [LiveTrain] {
        [
            LiveTrain(
                lineID: "C1",
                train: "23501",
                serviceDay: nil,
                delaySeconds: 180,
                status: .left,
                stopID: "54404",
                nextStopID: "54405",
                latitude: nil,
                longitude: nil,
                platform: nil,
                sampledAt: now
            ),
            LiveTrain(
                lineID: "C1",
                train: "23510",
                serviceDay: nil,
                delaySeconds: 0,
                status: .left,
                stopID: "54100",
                nextStopID: "54408",
                latitude: nil,
                longitude: nil,
                platform: nil,
                sampledAt: now
            ),
            LiveTrain(
                lineID: "C2",
                train: "26003",
                serviceDay: nil,
                delaySeconds: nil,
                status: .at,
                stopID: "54501",
                nextStopID: "54502",
                latitude: nil,
                longitude: nil,
                platform: "1",
                sampledAt: now
            ),
        ]
    }

    static func alerts(now: Date = .now) -> [ServiceAlert] {
        [
            ServiceAlert(
                id: "AVISO_514711",
                kind: .notice,
                lineIDs: ["C1", "C2"],
                since: now.addingTimeInterval(-12 * 60),
                until: nil,
                text:
                    "Renfe Cercanías Málaga informa que la estación de Victoria kent no es accesible temporalmente para PMR por avería del ascensor. Rogamos disculpen las molestias.",
                position: 0
            ),
            ServiceAlert(
                id: "INFO_465103",
                kind: .info,
                lineIDs: ["C1"],
                since: now.addingTimeInterval(-3 * 86_400),
                until: nil,
                text:
                    "Renfe Cercanías Málaga informa que la estación de Plaza Mayor no es accesible temporalmente para PMR. Rogamos disculpen las molestias",
                position: 1
            ),
            ServiceAlert(
                id: "INFO_465080",
                kind: .info,
                lineIDs: ["C1", "C2"],
                since: Calendar.current.date(byAdding: .year, value: -1, to: now),
                until: nil,
                text:
                    "Renfe Cercanías Málaga informa que andén 2 dirección Málaga, de la estación de Los Álamos, no es accesible temporalmente para PMR. Rogamos disculpen las molestias.",
                position: 2
            ),
        ]
    }
}

extension ServiceAlertItem {
    static let samples = ServiceAlertItemBuilder.items(
        alerts: SampleData.alerts(),
        lines: LineSample.all.map {
            Line(id: $0.id, name: $0.name, colorHex: $0.colorHex, shape: $0.shape)
        },
        now: .now,
        calendar: .autoupdatingCurrent,
        locale: .autoupdatingCurrent,
        dateLocale: .autoupdatingCurrent
    )
}

extension AlertTranslation {
    static var preview: Self {
        let items = ServiceAlertItem.samples
        var translation = AlertTranslation()
        items.prefix(2).forEach { translation.toggle($0.id) }
        translation.store(
            items.prefix(1).map {
                TranslationSession.Response(
                    sourceLanguage: AlertTranslationSupport.source,
                    targetLanguage: Locale.Language(identifier: "en"),
                    sourceText: $0.text,
                    targetText:
                        "Renfe Cercanías Málaga reports that Victoria Kent station is temporarily not accessible for people with reduced mobility due to a lift breakdown. We apologise for any inconvenience.",
                    clientIdentifier: $0.id
                )
            },
            for: items
        )
        return translation
    }
}

struct SampleDataContext {
    let container: ModelContainer
    let favorites: FavoritesViewModel
}

struct SampleDataPreview<Scenario: SampleDataScenario>: PreviewModifier {
    static func makeSharedContext() async throws -> SampleDataContext {
        let container = try ModelContainer(
            for: Schema(RailSchema.models),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        SampleData.insertNetwork(into: container.mainContext)
        Scenario.populate(container.mainContext)
        try container.mainContext.save()
        return SampleDataContext(
            container: container,
            favorites: FavoritesViewModel(
                repository: SwiftDataUserStationsRepository(
                    modelContainer: container
                )
            )
        )
    }

    func body(content: Content, context: SampleDataContext) -> some View {
        content
            .modelContainer(context.container)
            .environment(\.routeEstimates, PreviewRouteService())
            .environment(context.favorites)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var nextTrainsSampleData: Self {
        .modifier(SampleDataPreview<NetworkScenario>())
    }

    static var favoriteStationsSampleData: Self {
        .modifier(SampleDataPreview<FavoriteStationsScenario>())
    }

    static var stationTimetableSampleData: Self {
        .modifier(SampleDataPreview<StationTimetableScenario>())
    }

    static var savedStationSampleData: Self {
        .modifier(SampleDataPreview<SavedStationScenario>())
    }

    static var serviceAlertsSampleData: Self {
        .modifier(SampleDataPreview<ServiceAlertsScenario>())
    }

    static var noServiceAlertsSampleData: Self {
        .modifier(SampleDataPreview<EmptyServiceAlertsScenario>())
    }

    static var liveTrainsSampleData: Self {
        .modifier(SampleDataPreview<LiveTrainsScenario>())
    }
}
#endif
