import SwiftData
import SwiftUI

struct StationSheet: View {
    let bodyScrolls: Bool
    let actions: MapSheetActions

    @Query private var stations: [Station]

    init(
        stationID: String,
        bodyScrolls: Bool,
        actions: MapSheetActions
    ) {
        _stations = Query(filter: #Predicate<Station> { $0.id == stationID })
        self.bodyScrolls = bodyScrolls
        self.actions = actions
    }

    var body: some View {
        let station = stations.first
        MapSheet(bodyScrolls: bodyScrolls, actions: actions) {
            StationSheetHeader(station: station, onClose: actions.close)
        } content: {
            if let station {
                StationSummary(station: station)
            } else {
                ContentUnavailableView(
                    Self.unavailableTitle,
                    systemImage: "mappin.slash"
                )
            }
        }
    }

    private static let unavailableTitle = LocalizedStringResource(
        "Estación no disponible",
        comment:
            "Detalle de estación: la estación ya no está en los datos descargados."
    )
}

#if DEBUG
    private struct StationSheetSample: View {
        let stationID: String

        var body: some View {
            StationSheet(
                stationID: stationID,
                bodyScrolls: true,
                actions: MapSheetActions(
                    drag: { _ in },
                    close: {},
                    measure: { _, _ in }
                )
            )
            .frame(height: 440)
            .mapSheetSurface()
            .padding(ScreenLayout.margin)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .background(
                LinearGradient(
                    colors: [.green.opacity(0.4), .blue.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    #Preview("Resumen", traits: .mapSampleData) {
        StationSheetSample(stationID: "54413")
            .environment(LocationViewModel.preview())
    }

    #Preview("No disponible", traits: .mapSampleData) {
        StationSheetSample(stationID: "00000")
            .environment(LocationViewModel.preview())
    }

    #Preview("Sin permiso", traits: .mapSampleData) {
        StationSheetSample(stationID: "54413")
            .environment(LocationViewModel.preview(authorization: .notDetermined))
    }

    #Preview("Sin horarios", traits: .nextTrainsSampleData) {
        StationSheetSample(stationID: "54413")
            .environment(LocationViewModel.preview())
    }

    #Preview("Dynamic Type", traits: .mapSampleData) {
        StationSheetSample(stationID: "54413")
            .environment(LocationViewModel.preview())
            .dynamicTypeSize(.accessibility3)
    }
#endif
