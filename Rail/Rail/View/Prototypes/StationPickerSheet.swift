import SwiftData
import SwiftUI

struct StationPickerSheet: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Station.name) private var stations: [Station]
    @Query(SavedStation.current) private var savedStations: [SavedStation]
    @State private var query = ""

    private var savedStationID: String? { savedStations.first?.stationID }

    private var filtered: [Station] {
        query.isEmpty
            ? stations
            : stations.filter { $0.name.localizedStandardContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                if savedStationID != nil {
                    Section {
                        Button("Usar mi ubicación", systemImage: "location") {
                            location.clearSavedLocation()
                            dismiss()
                        }
                    }
                }

                Section("Estaciones") {
                    ForEach(filtered) { station in
                        row(for: station)
                    }
                }
            }
            .searchable(text: $query, prompt: "Buscar estación")
            .navigationTitle("Elegir estación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func row(for station: Station) -> some View {
        let isSaved = savedStationID == station.id
        let saved = SavedLocation(station: station)

        return Button {
            location.saveLocation(saved)
            dismiss()
        } label: {
            HStack(spacing: Spacing.sm) {
                StationSummaryRow(
                    station: station,
                    distance: location.distance(to: station.coordinate)
                )
                if isSaved {
                    Spacer(minLength: Spacing.sm)
                    Image(systemName: "checkmark")
                        .foregroundStyle(.brandPrimary)
                }
            }
        }
        .foregroundStyle(.textPrimary)
        .accessibilityAddTraits(isSaved ? .isSelected : [])
    }
}

#if DEBUG
#Preview("Sin estación guardada", traits: .nextTrainsSampleData) {
    StationPickerSheet()
        .environment(LocationViewModel.preview())
}

#Preview("Fuengirola guardada", traits: .savedStationSampleData) {
    StationPickerSheet()
        .environment(LocationViewModel.preview(authorization: .denied))
}
#endif
