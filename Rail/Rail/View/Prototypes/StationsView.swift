//
//  StationsView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData

struct StationsView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var favorites: [FavoriteStation]

    private var favoriteIDs: Set<String> {
        Set(favorites.map(\.stationID))
    }

    var body: some View {
        NavigationStack {
            List {
                NearbyStationsSection(stations: stations)

                Section("Todas las estaciones") {
                    ForEach(stations) { station in
                        NavigationLink {
                            StationDetailView(station: station)
                        } label: {
                            StationRow(
                                StationRowItemBuilder.item(
                                    for: station,
                                    location: location.location
                                ),
                                isFavorite: favoritesModel.binding(
                                    for: station.id,
                                    isFavorite: favoriteIDs.contains(station.id)
                                ),
                                showsSeparator: false
                            )
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
            .overlay {
                if stations.isEmpty {
                    ContentUnavailableView(
                        "Sin estaciones",
                        systemImage: "mappin.slash"
                    )
                }
            }
            .navigationTitle("Estaciones")
        }
    }
}

#if DEBUG
#Preview(traits: .favoriteStationsSampleData) {
    StationsView()
        .environment(LocationViewModel.preview())
}
#endif
