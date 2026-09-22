import SwiftData
import SwiftUI

struct NearbyStationsSection: View {
    let stations: [Station]

    @Environment(LocationViewModel.self) private var location

    var body: some View {
        if !stations.isEmpty {
            Section("Cerca de ti") {
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if location.canRequestAccess || location.isAccessBlocked {
            LocationAccessPrompt(
                message:
                    "Activa la ubicación para ver qué estaciones tienes más cerca y a qué distancia están."
            )
        } else if location.isLocating {
            HStack(spacing: Spacing.sm) {
                ProgressView()
                Text("Buscando tu ubicación…")
                    .foregroundStyle(.textSecondary)
            }
        } else {
            ForEach(location.nearest(stations)) { nearby in
                NavigationLink {
                    StationDetailView(station: nearby.station)
                } label: {
                    StationRow(
                        station: nearby.station,
                        distance: nearby.distance
                    )
                }
            }
        }
    }
}

// MARK: - Previews

extension Station {
    fileprivate static func nearbySamples() -> [Station] {
        [
            Station(
                id: "54413",
                name: "Málaga-Centro Alameda",
                latitude: 36.7170,
                longitude: -4.4250
            ),
            Station(
                id: "54404",
                name: "Málaga María Zambrano",
                latitude: 36.7119,
                longitude: -4.4315
            ),
            Station(
                id: "54100",
                name: "Fuengirola",
                latitude: 36.5397,
                longitude: -4.6262
            ),
        ]
    }
}

#Preview("Con ubicación") {
    NavigationStack {
        List {
            NearbyStationsSection(stations: Station.nearbySamples())
        }
    }
    .environment(LocationViewModel.preview())
    .modelContainer(for: [TransitNetwork.self, Timetable.self], inMemory: true)
}

#Preview("Sin permiso") {
    NavigationStack {
        List {
            NearbyStationsSection(stations: Station.nearbySamples())
        }
    }
    .environment(LocationViewModel.preview(authorization: .notDetermined))
    .modelContainer(for: [TransitNetwork.self, Timetable.self], inMemory: true)
}

#Preview("Permiso denegado") {
    NavigationStack {
        List {
            NearbyStationsSection(stations: Station.nearbySamples())
        }
    }
    .environment(LocationViewModel.preview(authorization: .denied))
    .modelContainer(for: [TransitNetwork.self, Timetable.self], inMemory: true)
}

#Preview("Buscando") {
    NavigationStack {
        List {
            NearbyStationsSection(stations: Station.nearbySamples())
        }
    }
    .environment(LocationViewModel.preview(location: nil))
    .modelContainer(for: [TransitNetwork.self, Timetable.self], inMemory: true)
}
