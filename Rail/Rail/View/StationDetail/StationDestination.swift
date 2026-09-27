import SwiftData
import SwiftUI

struct StationDestination: View {
    @Query private var stations: [Station]

    init(stationID: String) {
        _stations = Query(filter: #Predicate<Station> { $0.id == stationID })
    }

    var body: some View {
        if let station = stations.first {
            StationDetailView(station: station)
        } else {
            ContentUnavailableView(
                LocalizedStringResource(
                    "Estación no disponible",
                    comment: "Detalle de estación: la estación ya no está en los datos descargados."
                ),
                systemImage: "mappin.slash"
            )
        }
    }
}

#if DEBUG
#Preview("Estación", traits: .favoriteStationsSampleData) {
    NavigationStack {
        StationDestination(stationID: "54413")
    }
    .environment(LocationViewModel.preview())
}

#Preview("No disponible", traits: .nextTrainsSampleData) {
    NavigationStack {
        StationDestination(stationID: "00000")
    }
    .environment(LocationViewModel.preview())
}
#endif
