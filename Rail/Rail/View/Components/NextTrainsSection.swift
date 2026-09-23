import SwiftData
import SwiftUI
import UIKit

struct NextTrainsSection: View {
    let onShowMap: (String) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.routeEstimates) private var routeEstimates
    @Environment(\.openURL) private var openURL
    @Environment(LocationViewModel.self) private var location
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @Query(SavedStation.current) private var savedStations: [SavedStation]
    @State private var schedules: NextTrainsSchedules?
    @State private var walking: WalkingResult?
    @State private var isChoosingStation = false

    private struct ScheduleRequest: Equatable {
        let stationID: String
        let timetableKey: String
        let serviceDay: Date
    }

    private var network: TransitNetwork? { networks.first }

    private var timetable: Timetable? { timetables.first }

    private var calendar: Calendar { network?.calendar ?? .autoupdatingCurrent }

    private var timeZone: TimeZone { network?.timeZone ?? .autoupdatingCurrent }

    private var target: NextTrainsTarget {
        NextTrainsCardStateBuilder.target(
            authorization: location.authorization,
            location: location.location,
            hasLocationFailed: location.hasLocationFailed,
            savedLocation: savedStations.first.map(SavedLocation.init),
            stations: stations
        )
    }

    private var walkingRequest: WalkingRequest? {
        switch (target, location.location) {
        case (.station(let station, source: .device), let origin?):
            WalkingRequest(origin: origin.cell, stationID: station.id)
        default:
            nil
        }
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let request = scheduleRequest(at: context.date)
            NextTrainsCard(state(at: context.date), onAction: handle)
                .task(id: request) { loadSchedules(request) }
        }
        .task(id: walkingRequest) { await loadWalking(walkingRequest) }
        .sheet(isPresented: $isChoosingStation) { StationPickerSheet() }
    }

    private func state(at date: Date) -> NextTrainsCardState {
        NextTrainsCardStateBuilder.state(
            target: target,
            schedules: schedules,
            walking: walking,
            now: date,
            timeZone: timeZone
        )
    }

    private func scheduleRequest(at date: Date) -> ScheduleRequest? {
        guard let station = target.station, let timetable else { return nil }
        return ScheduleRequest(
            stationID: station.id,
            timetableKey: timetable.etag ?? timetable.version,
            serviceDay: calendar.startOfDay(for: date)
        )
    }

    private func loadSchedules(_ request: ScheduleRequest?) {
        guard let request, let station = target.station, let timetable else {
            return
        }
        schedules = NextTrainsScheduleBuilder.schedules(
            for: station,
            timetable: timetable,
            day: request.serviceDay,
            calendar: calendar,
            context: modelContext
        )
    }

    private func loadWalking(_ request: WalkingRequest?) async {
        guard let request, let origin = location.location,
            let station = target.station
        else { return }
        let estimates = await routeEstimates.estimates(
            from: origin.coordinate,
            to: station.coordinate,
            modes: [.walking]
        )
        guard !Task.isCancelled else { return }
        walking = WalkingResult(request: request, estimate: estimates[.walking])
    }

    private func handle(_ action: NextTrainsCardAction) {
        switch action {
        case .requestLocation:
            location.requestAccess()
        case .openSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
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
