//
//  SyncService.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import Foundation

enum SyncOutcome: Sendable, Equatable {
    case unchanged
    case updated
}

struct SyncStatus: Sendable, Equatable {
    let freshness: DataFreshness
    let lastFetchedAt: Date?
}

protocol SyncService: Sendable {
    func status(now: Date) async throws -> SyncStatus
    @discardableResult
    func sync(now: Date) async throws -> SyncOutcome
    func cancel() async
}

@SyncActor
final class SyncServiceImpl: SyncService {

    private let api: any APIService
    private let repository: any TransitRepository
    private let policy: DataFreshnessPolicy
    private var inFlight: Task<SyncOutcome, any Error>?

    nonisolated init(
        api: any APIService,
        repository: any TransitRepository,
        policy: DataFreshnessPolicy = .standard
    ) {
        self.api = api
        self.repository = repository
        self.policy = policy
    }

    @SyncActor
    func status(now: Date) async throws -> SyncStatus {
        let state = try await repository.localState()
        return SyncStatus(
            freshness: policy.freshness(of: state, now: now),
            lastFetchedAt: state.lastFetchedAt
        )
    }

    @discardableResult
    @SyncActor
    func sync(now: Date) async throws -> SyncOutcome {
        while let running = inFlight {
            guard running.isCancelled else {
                return try await running.value
            }
            _ = try? await running.value
            clearIfCurrent(running)
        }

        let task = Task { @concurrent [api, repository] in
            try await Self.performSync(
                api: api,
                repository: repository,
                now: now
            )
        }
        inFlight = task

        defer { clearIfCurrent(task) }
        return try await task.value
    }

    @SyncActor
    func cancel() async {
        inFlight?.cancel()
    }

    private func clearIfCurrent(_ task: Task<SyncOutcome, any Error>) {
        if inFlight == task {
            inFlight = nil
        }
    }

    @concurrent
    private nonisolated static func performSync(
        api: any APIService,
        repository: any TransitRepository,
        now: Date
    ) async throws -> SyncOutcome {
        let state = try await repository.localState()

        async let networkResponse = api.getNetwork(etag: state.networkETag)
        async let timetableResponse = api.getTimetable(
            etag: state.timetableETag
        )

        let network: ETagged<NetworkResponseDTO>?
        let timetable: ETagged<TimetableResponseDTO>?

        do {
            network = try await networkResponse.payload()
            timetable = try await timetableResponse.payload()
        } catch NetworkError.cancelled {
            throw CancellationError()
        }

        try Task.checkCancellation()

        if let network {
            try await repository.importNetwork(
                network.value,
                etag: network.etag,
                fetchedAt: now
            )
        }

        try Task.checkCancellation()

        if let timetable {
            try await repository.importTimetable(
                timetable.value,
                etag: timetable.etag,
                fetchedAt: now
            )
        }

        return network == nil && timetable == nil ? .unchanged : .updated
    }
}
