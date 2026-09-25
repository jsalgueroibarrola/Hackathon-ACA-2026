import Foundation
import SwiftData

@Model
final class LiveTrain {
    #Index<LiveTrain>([\.lineID, \.train])

    var lineID: String
    var train: String
    var serviceDay: Date?
    var delaySeconds: Int?
    var statusRaw: String
    var stopID: String?
    var nextStopID: String?
    var latitude: Double?
    var longitude: Double?
    var positionSampledAt: Date?
    var platform: String?
    var sampledAt: Date?
    var directionRaw: Int?

    var feed: RealtimeFeed?

    init(
        lineID: String,
        train: String,
        serviceDay: Date?,
        delaySeconds: Int?,
        status: LiveStatus,
        stopID: String?,
        nextStopID: String?,
        latitude: Double?,
        longitude: Double?,
        positionSampledAt: Date? = nil,
        platform: String?,
        sampledAt: Date?,
        direction: TripDirection? = nil
    ) {
        self.lineID = lineID
        self.train = train
        self.serviceDay = serviceDay
        self.delaySeconds = delaySeconds
        self.statusRaw = status.rawValue
        self.stopID = stopID
        self.nextStopID = nextStopID
        self.latitude = latitude
        self.longitude = longitude
        self.positionSampledAt = positionSampledAt
        self.platform = platform
        self.sampledAt = sampledAt
        self.directionRaw = direction?.rawValue
    }
}

extension LiveTrain {
    var status: LiveStatus {
        LiveStatus(rawValue: statusRaw) ?? .unknown
    }

    var direction: TripDirection? {
        directionRaw.flatMap(TripDirection.init(rawValue:))
    }

    convenience init(record: LiveTrainRecord) {
        self.init(
            lineID: record.lineID,
            train: record.train,
            serviceDay: record.serviceDay,
            delaySeconds: record.delaySeconds,
            status: record.status,
            stopID: record.stopID,
            nextStopID: record.nextStopID,
            latitude: record.latitude,
            longitude: record.longitude,
            positionSampledAt: record.positionSampledAt,
            platform: record.platform,
            sampledAt: record.sampledAt,
            direction: record.direction
        )
    }

    var record: LiveTrainRecord {
        LiveTrainRecord(
            lineID: lineID,
            train: train,
            serviceDay: serviceDay,
            delaySeconds: delaySeconds,
            status: status,
            stopID: stopID,
            nextStopID: nextStopID,
            latitude: latitude,
            longitude: longitude,
            positionSampledAt: positionSampledAt,
            platform: platform,
            sampledAt: sampledAt,
            direction: direction
        )
    }
}

struct LiveTrainRecord: Sendable, Equatable {
    var lineID: String
    var train: String
    var serviceDay: Date?
    var delaySeconds: Int?
    var status: LiveStatus
    var stopID: String?
    var nextStopID: String?
    var latitude: Double?
    var longitude: Double?
    var positionSampledAt: Date?
    var platform: String?
    var sampledAt: Date?
    var direction: TripDirection?

    var key: String { "\(lineID)-\(train)" }

    var hasPosition: Bool { latitude != nil && longitude != nil }
}

enum LiveStatus: String, Codable, CaseIterable, Sendable {
    case at
    case left
    case approaching
    case unknown
}
