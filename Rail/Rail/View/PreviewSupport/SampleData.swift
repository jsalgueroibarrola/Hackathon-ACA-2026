#if DEBUG
import SwiftData
import SwiftUI

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

enum SavedStationScenario: SampleDataScenario {
    static func populate(_ context: ModelContext) {
        context.insert(SavedStation(.fuengirola))
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

    static var savedStationSampleData: Self {
        .modifier(SampleDataPreview<SavedStationScenario>())
    }
}
#endif
