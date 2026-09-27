import SwiftData
import SwiftUI

private struct SyncTrigger: Equatable {
    let isBackgrounded: Bool
    let retryAttempt: Int
}

struct RootView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(OnboardingView.completionKey) private var hasCompletedOnboarding = false
    @State private var retryAttempt = 0

    private var trigger: SyncTrigger {
        SyncTrigger(
            isBackgrounded: scenePhase == .background,
            retryAttempt: retryAttempt
        )
    }

    private var hasDownloadFailed: Bool {
        if case .failed = viewModel.phase { true } else { false }
    }

    var body: some View {
        root
            .animation(.smooth, value: viewModel.phase)
            .animation(.smooth, value: hasCompletedOnboarding)
            .task(id: trigger) {
                guard !trigger.isBackgrounded else { return }
                await viewModel.synchronize()
            }
    }

    @ViewBuilder
    private var root: some View {
        if hasCompletedOnboarding {
            content
        } else {
            OnboardingView(hasDownloadFailed: hasDownloadFailed) {
                hasCompletedOnboarding = true
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .checking:
            LaunchScreenView()

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

#if DEBUG
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
        .environment(LocationViewModel.preview())
        .environment(FavoritesViewModel.preview())
        .modelContainer(for: RailSchema.models, inMemory: true)
}
#endif
