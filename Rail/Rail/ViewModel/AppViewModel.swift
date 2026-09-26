import Foundation
import Observation
import OSLog

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
        let now = Date.now
        var freshness = DataFreshness.missing
        let failure: (any Error)?
        do {
            let status = try await syncService.status(now: now)
            try Task.checkCancellation()
            freshness = status.freshness
            lastFetchedAt = status.lastFetchedAt
            phase = freshness.requiresBlockingDownload ? .loading : .ready(.refreshing)
            if try await syncService.sync(now: now) == .updated {
                WidgetReloader.reloadNextTrains()
            }
            lastFetchedAt = (try? await syncService.status(now: .now))?.lastFetchedAt ?? lastFetchedAt
            failure = nil
        } catch {
            failure = error
        }
        guard !Task.isCancelled else { return }
        if let failure, !(failure is CancellationError) {
            Logger.sync.error("Sync failed: \(String(describing: failure), privacy: .public)")
        }
        phase = Self.phase(for: freshness, failure: failure)
    }

    static func phase(for freshness: DataFreshness, failure: (any Error)?) -> AppPhase {
        switch (freshness.requiresBlockingDownload, failure) {
        case (_, nil):
            .ready(.idle)
        case (true, let error?) where error is CancellationError:
            .failed(
                String(
                    localized: "Se ha interrumpido la descarga de horarios",
                    comment: "Descripción de error mostrada cuando la sincronización inicial se cancela."
                )
            )
        case (true, let error?):
            .failed(failureMessage(for: error))
        case (false, let error?) where error is CancellationError:
            .ready(.idle)
        case (false, _?):
            .ready(freshness.warnsOnFailedRefresh ? .failed : .idle)
        }
    }

    private static func failureMessage(for error: any Error) -> String {
        switch error {
        case NetworkError.transport:
            String(
                localized: "No hay conexión a internet. Comprueba la conexión e inténtalo de nuevo.",
                comment: "Descripción de error cuando la descarga inicial de horarios falla por no tener conexión."
            )
        case NetworkError.status, NetworkError.serviceUnavailable:
            String(
                localized: "El servidor de horarios no responde. Inténtalo de nuevo más tarde.",
                comment: "Descripción de error cuando el servidor de horarios devuelve un error en la descarga inicial."
            )
        default:
            String(
                localized: "No se han podido descargar los horarios. Inténtalo de nuevo.",
                comment: "Descripción de error genérica cuando falla la descarga inicial de horarios."
            )
        }
    }
}
