//
//  DataFreshnessPolicy.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

enum DataFreshness: Sendable, Equatable {
    case missing
    case expired
    case stale
    case fresh
}

extension DataFreshness {
    var requiresBlockingDownload: Bool {
        self == .missing || self == .expired
    }

    var warnsOnFailedRefresh: Bool {
        self == .stale
    }
}

struct DataFreshnessPolicy: Sendable {
    var minimumCoverageDays: Int = 3
    var revalidationInterval: TimeInterval = 12 * 60 * 60

    static let standard = DataFreshnessPolicy()

    func freshness(of state: LocalDataState, now: Date) -> DataFreshness {
        guard state.hasNetwork,
            let startDay = state.startDay,
            let endDay = state.endDay
        else {
            return .missing
        }

        let calendar = state.calendar
        let today = calendar.startOfDay(for: now)
        let firstDay = calendar.startOfDay(for: startDay)
        let lastDay = calendar.startOfDay(for: endDay)

        guard today >= firstDay, today <= lastDay else {
            return .expired
        }

        let remainingDays =
            calendar
            .dateComponents([.day], from: today, to: lastDay)
            .day ?? 0

        let elapsed =
            state.lastFetchedAt.map(now.timeIntervalSince) ?? .infinity

        return remainingDays < minimumCoverageDays
            || elapsed >= revalidationInterval
            ? .stale
            : .fresh
    }
}
