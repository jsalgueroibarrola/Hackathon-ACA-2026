import SwiftData
import SwiftUI

struct NextTrainsSection: View {
    let onShowMap: (String) -> Void

    @Environment(\.openURL) private var openURL
    @Environment(LocationViewModel.self) private var location
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @Query(SavedStation.current) private var savedStations: [SavedStation]
    @State private var schedules: NextTrainsSchedules?
    @State private var walking: RouteEstimates?
    @State private var isChoosingStation = false

    private var target: NextTrainsTarget {
        NextTrainsCardStateBuilder.target(
            authorization: location.authorization,
            location: location.location,
            hasLocationFailed: location.hasLocationFailed,
            savedLocation: savedStations.first.map(SavedLocation.init),
            stations: stations
        )
    }

    private var walkingRequest: RouteEstimateRequest? {
        switch (target, location.location) {
        case (.station(let station, source: .device), let origin?):
            RouteEstimateRequest(from: origin, to: station, modes: [.walking])
        default:
            nil
        }
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            NextTrainsCard(state(at: context.date), onAction: handle)
                .loadSchedules(scheduleRequest(at: context.date), into: $schedules) {
                    try await $0.nextTrains(for: $1)
                }
        }
        .loadRouteEstimates(walkingRequest, into: $walking)
        .sheet(isPresented: $isChoosingStation) { stationPicker }
    }

    private var stationPicker: some View {
        StationPickerSheet(
            selection: Set(savedStations.map(\.stationID)),
            onPick: saveStation
        ) {
            if !savedStations.isEmpty {
                Button(Self.useLocationLabel, systemImage: "location") {
                    location.clearSavedLocation()
                    isChoosingStation = false
                }
            }
        }
    }

    private func saveStation(_ stationID: String) {
        if let station = stations.first(where: { $0.id == stationID }) {
            location.saveLocation(SavedLocation(station: station))
        }
    }

    private static let useLocationLabel = LocalizedStringResource(
        "Usar mi ubicación",
        comment: "Selector de estación habitual: fila que borra la estación guardada y vuelve a usar la ubicación del dispositivo."
    )

    private func state(at date: Date) -> NextTrainsCardState {
        NextTrainsCardStateBuilder.state(
            target: target,
            schedules: schedules,
            walking: walking,
            now: date
        )
    }

    private func scheduleRequest(at date: Date) -> ScheduleRequest? {
        ScheduleRequest(
            stationID: target.station?.id,
            timetable: timetables.first,
            network: networks.first,
            at: date
        )
    }

    private func handle(_ action: NextTrainsCardAction) {
        switch action {
        case .requestLocation:
            location.requestAccess()
        case .openSettings:
            if let settings = URL.appSettings {
                openURL(settings)
            }
        case .retryLocation:
            location.retry()
        case .chooseStation:
            isChoosingStation = true
        case .showMap:
            if case .noStationNearby(let nearest) = target {
                onShowMap(nearest.station.id)
            }
        }
    }
}

#if DEBUG
private struct NextTrainsSectionPreview: View {
    var body: some View {
        ScrollView {
            NextTrainsSection { _ in }
                .padding(ScreenLayout.margin)
        }
        .background(.bgSecondary)
    }
}

#Preview("Cerca de una estación", traits: .nextTrainsSampleData) {
    NextTrainsSectionPreview()
        .environment(LocationViewModel.preview(location: .alameda))
}

#Preview("Sin permiso", traits: .nextTrainsSampleData) {
    NextTrainsSectionPreview()
        .environment(LocationViewModel.preview(authorization: .notDetermined))
}

#Preview("Permiso denegado", traits: .nextTrainsSampleData) {
    NextTrainsSectionPreview()
        .environment(LocationViewModel.preview(authorization: .denied))
}

#Preview("Buscando", traits: .nextTrainsSampleData) {
    NextTrainsSectionPreview()
        .environment(LocationViewModel.preview(location: nil))
}

#Preview("Sin ubicación", traits: .nextTrainsSampleData) {
    NextTrainsSectionPreview()
        .environment(
            LocationViewModel.preview(
                location: nil,
                isLocationUnavailable: true
            )
        )
}

#Preview("Fuera de zona", traits: .nextTrainsSampleData) {
    NextTrainsSectionPreview()
        .environment(LocationViewModel.preview(location: .madrid))
}

#Preview("Estación guardada", traits: .savedStationSampleData) {
    NextTrainsSectionPreview()
        .environment(LocationViewModel.preview(authorization: .denied))
}
#endif
