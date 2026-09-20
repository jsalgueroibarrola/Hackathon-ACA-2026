//
//  Repository.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

protocol Repository: Sendable {
    func localState() async throws -> LocalDataState
    func importNetwork(
        _ dto: NetworkResponseDTO,
        etag: String?,
        fetchedAt: Date
    ) async throws
    func importTimetable(
        _ dto: TimetableResponseDTO,
        etag: String?,
        fetchedAt: Date
    ) async throws
}
