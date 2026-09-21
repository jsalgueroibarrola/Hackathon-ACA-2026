import Foundation
import SwiftData

@Model
final class LineStop {
    #Unique<LineStop>([\.lineID, \.sequence])
    #Index<LineStop>([\.stationID], [\.lineID, \.sequence])

    /// ``Line/id`` of the owning line. Denormalised from ``line`` so indexes and predicates can use it.
    var lineID: String
    /// ``Station/id`` of the station called at. Denormalised from ``station`` for the same reason.
    var stationID: String
    /// Position in the payload's station list, that is, travel order for ``TripDirection/outbound``.
    var sequence: Int

    var line: Line?
    var station: Station?

    init(lineID: String, stationID: String, sequence: Int) {
        self.lineID = lineID
        self.stationID = stationID
        self.sequence = sequence
    }
}
