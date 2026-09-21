//
//  AppViewModel.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import Foundation
import Observation

enum AppPhase: Equatable {
    case checking
    case loading
    case ready(RefreshState)
    case failed(String)
}

enum RefreshState: Equatable {
    case idle
    case refreshing
    case failed
}

@MainActor
@Observable
final class AppViewModel {

    private(set) var phase: AppPhase = .checking
    private(set) var lastFetchedAt: Date?

    private let syncService: any SyncService

    init(syncService: any SyncService) {
        self.syncService = syncService
    }

    func synchronize() async {
        await withTaskCancellationHandler {
            await evaluate()
        } onCancel: { [syncService] in
            Task { await syncService.cancel() }
        }
    }

    private func evaluate() async {
        let now = Date()

        let status: SyncStatus
        do {
            status = try await syncService.status(now: now)
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed(error.localizedDescription)
            return
        }

        guard !Task.isCancelled else { return }

        let blocking = status.freshness.requiresBlockingDownload
        lastFetchedAt = status.lastFetchedAt
        phase = blocking ? .loading : .ready(.refreshing)

        do {
            try await syncService.sync(now: now)
        } catch is CancellationError {
            guard !Task.isCancelled else { return }
            phase = blocking
                ? .failed(
                    String(
                        localized: "Se ha interrumpido la descarga de horarios",
                        comment: "Descripción de error mostrada cuando la sincronización inicial se cancela."
                    )
                )
                : .ready(.idle)
            return
        } catch {
            guard !Task.isCancelled else { return }
            phase = blocking
                ? .failed(error.localizedDescription)
                : .ready(status.freshness.warnsOnFailedRefresh ? .failed : .idle)
            return
        }

        guard !Task.isCancelled else { return }

        if let refreshed = try? await syncService.status(now: Date()) {
            lastFetchedAt = refreshed.lastFetchedAt
        }
        phase = .ready(.idle)
    }
}
