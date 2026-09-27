import SwiftData
import SwiftUI

struct OnboardingView: View {
    static let completionKey = "hasCompletedOnboarding"

    private let hasDownloadFailed: Bool
    private let onFinish: () -> Void

    @Environment(LocationViewModel.self) private var location
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var path: [OnboardingStep] = []

    init(hasDownloadFailed: Bool, onFinish: @escaping () -> Void) {
        self.hasDownloadFailed = hasDownloadFailed
        self.onFinish = onFinish
    }

    private var step: OnboardingStep {
        path.last ?? .welcome
    }

    private var isSideBySide: Bool {
        verticalSizeClass == .compact && step.hasArtwork
    }

    var body: some View {
        NavigationStack(path: $path) {
            page(.welcome)
                .navigationDestination(for: OnboardingStep.self, destination: page)
        }
        .overlay(alignment: .top) { topBar }
        .accessibilityAction(.escape, goBack)
        .task(id: scenePhase == .active) {
            guard scenePhase == .active else { return }
            await location.observe()
        }
        .onChange(of: location.canRequestAccess) { wasPending, isPending in
            if wasPending, !isPending, step == .location {
                advance()
            }
        }
    }

    private func page(_ step: OnboardingStep) -> some View {
        Group {
            switch step {
            case .welcome:
                OnboardingWelcomePage(hasDownloadFailed: hasDownloadFailed, onContinue: advance)
            case .privacy:
                OnboardingPrivacyPage(onContinue: advance)
            case .location:
                OnboardingLocationPage(onContinue: advance)
            case .alerts:
                OnboardingAlertsPage(onContinue: advance)
            case .widgets:
                OnboardingWidgetsPage(onContinue: advance)
            case .stations:
                OnboardingStationsPage(hasDownloadFailed: hasDownloadFailed, onFinish: onFinish)
            }
        }
        .safeAreaBar(edge: .top, spacing: 0) {
            Color.clear
                .frame(height: OnboardingTopBar.height)
        }
        .background(.bgSecondary)
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            if isSideBySide {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: 0)
            }
            OnboardingTopBar(step: step, onBack: goBack)
                .frame(maxWidth: .infinity)
        }
        .accessibilitySortPriority(1)
        .animation(.smooth, value: step)
    }

    private func advance() {
        if let next = step.next {
            path.append(next)
        }
    }

    private func goBack() {
        _ = path.popLast()
    }
}

#if DEBUG
#Preview("Variantes Figma", traits: .nextTrainsSampleData) {
    OnboardingView(hasDownloadFailed: false) {}
        .environment(LocationViewModel.preview(authorization: .notDetermined))
}

#Preview("Descargando") {
    OnboardingView(hasDownloadFailed: false) {}
        .environment(LocationViewModel.preview(authorization: .notDetermined))
        .environment(FavoritesViewModel.preview())
        .modelContainer(for: RailSchema.models, inMemory: true)
}

#Preview("Modo oscuro", traits: .nextTrainsSampleData) {
    OnboardingView(hasDownloadFailed: false) {}
        .environment(LocationViewModel.preview(authorization: .notDetermined))
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type", traits: .nextTrainsSampleData) {
    OnboardingView(hasDownloadFailed: false) {}
        .environment(LocationViewModel.preview(authorization: .notDetermined))
        .dynamicTypeSize(.accessibility2)
}
#endif
