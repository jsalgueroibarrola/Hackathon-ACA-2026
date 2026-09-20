//
//  Calendar+ServiceDay.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

extension Calendar {
    func serviceDay(from value: String) -> Date? {
        let parts = value.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return date(
            from: DateComponents(year: parts[0], month: parts[1], day: parts[2])
        )
    }
}
