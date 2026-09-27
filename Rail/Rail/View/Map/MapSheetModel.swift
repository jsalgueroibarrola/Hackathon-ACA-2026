import Observation
import SwiftUI

@MainActor
@Observable
final class MapSheetModel {
    var origin: MapSheetOrigin = .bottom
    var dragTranslation: CGFloat?
    var lastStationID: String?
    private(set) var measurements = MapSheetMeasurements()

    func measure<Value: Equatable>(
        _ keyPath: WritableKeyPath<MapSheetMeasurements, Value>,
        _ value: Value
    ) {
        guard measurements[keyPath: keyPath] != value else { return }
        measurements[keyPath: keyPath] = value
    }
}
