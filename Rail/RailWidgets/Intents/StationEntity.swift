import AppIntents

struct StationEntity: AppEntity {
    let id: String
    let name: String

    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource(
            "Estación",
            comment:
                "Nombre del tipo de dato que se elige en la configuración del widget"
        )
    )

    static let defaultQuery = FavoriteStationQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct FavoriteStationQuery: EnumerableEntityQuery {
    typealias Entity = StationEntity

    func allEntities() async throws -> [StationEntity] {
        let favorites = RailWidgetStore.favoriteStations()
        return favorites.isEmpty ? RailWidgetStore.allStations() : favorites
    }

    func entities(for identifiers: [String]) async throws -> [StationEntity] {
        RailWidgetStore.stations(withIDs: identifiers)
    }
}
