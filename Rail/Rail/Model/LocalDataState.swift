//
//  LocalDataState.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

struct LocalDataState: Sendable, Equatable {
    var networkID: String?
    var timeZoneIdentifier: String?
    var networkETag: String?
    var timetableETag: String?
    var startDay: Date?
    var endDay: Date?
    var lastFetchedAt: Date?

    static let empty = LocalDataState()
}

extension LocalDataState {
    var hasNetwork: Bool {
        networkID != nil
    }

    var hasTimetable: Bool {
        startDay != nil && endDay != nil
    }

    var timeZone: TimeZone {
        timeZoneIdentifier.flatMap(TimeZone.init(identifier:)) ?? .gmt
    }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
