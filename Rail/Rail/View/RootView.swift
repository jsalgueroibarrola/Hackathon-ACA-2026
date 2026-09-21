//
//  RootView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData

private struct SyncTrigger: Equatable {
    let isBackgrounded: Bool
    let retryAttempt: Int
}

struct RootView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var retryAttempt = 0

    private var trigger: SyncTrigger {
        SyncTrigger(
            isBackgrounded: scenePhase == .background,
            retryAttempt: retryAttempt
        )
    }

    var body: some View {
        content
            .animation(.smooth, value: viewModel.phase)
            .task(id: trigger) {
                guard !trigger.isBackgrounded else { return }
                await viewModel.synchronize()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .checking:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loading:
            DataLoadingView()

        case .ready(let refresh):
            MainTabView()
                .safeAreaInset(edge: .bottom) {
                    if refresh == .failed {
                        RefreshBanner(lastFetchedAt: viewModel.lastFetchedAt)
                            .transition(
                                .move(edge: .bottom).combined(with: .opacity)
                            )
                    }
                }

        case .failed(let message):
            DataUnavailableView(message: message) {
                retryAttempt += 1
            }
        }
    }
}

private struct PreviewSyncService: SyncService {
    let freshness: DataFreshness

    func status(now: Date) async throws -> SyncStatus {
        SyncStatus(
            freshness: freshness,
            lastFetchedAt: .now.addingTimeInterval(-90_000)
        )
    }

    func sync(now: Date) async throws -> SyncOutcome {
        throw NetworkError.nonHTTP
    }

    func cancel() async {}
}

#Preview {
    RootView()
        .environment(
            AppViewModel(syncService: PreviewSyncService(freshness: .stale))
        )
        .modelContainer(for: TransitNetwork.self, inMemory: true)
}
