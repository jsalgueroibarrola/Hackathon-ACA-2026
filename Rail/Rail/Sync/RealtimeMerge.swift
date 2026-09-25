import Foundation

enum RealtimeMerge {
    static let retention: TimeInterval = 120

    static func merge(
        previous: [LiveTrainRecord],
        incoming: [LiveTrainRecord],
        now: Date
    ) -> [LiveTrainRecord] {
        let previousByKey = Dictionary(
            previous.map { ($0.key, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let incomingKeys = Set(incoming.map(\.key))

        let updated = incoming.map { record in
            carryingOver(from: previousByKey[record.key], into: record)
        }
        let retained = previous.filter { record in
            !incomingKeys.contains(record.key)
                && record.nextStopID != nil
                && now.timeIntervalSince(record.sampledAt ?? .distantPast)
                    < retention
        }
        return updated + retained
    }

    private static func carryingOver(
        from previous: LiveTrainRecord?,
        into record: LiveTrainRecord
    ) -> LiveTrainRecord {
        var merged = record
        merged.direction = record.direction ?? previous?.direction
        merged.positionSampledAt = record.sampledAt

        guard !record.hasPosition,
            let previous,
            previous.nextStopID == record.nextStopID
        else { return merged }

        merged.latitude = previous.latitude
        merged.longitude = previous.longitude
        merged.positionSampledAt =
            previous.positionSampledAt ?? previous.sampledAt
        return merged
    }
}
