import SwiftUI

struct OnboardingTopBar: View {
    private let step: OnboardingStep
    private let onBack: () -> Void

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private static let bottomInset: CGFloat = 10

    static let height = Size.touchMin + bottomInset

    init(step: OnboardingStep, onBack: @escaping () -> Void) {
        self.step = step
        self.onBack = onBack
    }

    private var isOverPhoto: Bool {
        step == .welcome && verticalSizeClass != .compact
    }

    var body: some View {
        ZStack(alignment: .leading) {
            progress
                .frame(maxWidth: .infinity)
            if step.previous != nil {
                backButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: Size.touchMin)
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.bottom, Self.bottomInset)
    }

    private var backButton: some View {
        Button(action: onBack) {
            Label(Self.backLabel, systemImage: "chevron.left")
        }
        .labelStyle(.iconOnly)
        .fontWeight(.semibold)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.large)
    }

    private var progress: some View {
        StepIndicator(count: OnboardingStep.count, current: step.rawValue)
            .foregroundStyle(isOverPhoto ? Color.white : .textSecondary)
            .tint(isOverPhoto ? Color.white : .accentColor)
            .accessibilityElement()
            .accessibilityLabel(Text(step.accessibilityLabel))
    }

    private static let backLabel = LocalizedStringResource(
        "Atrás",
        comment: "Bienvenida: botón con una flecha que vuelve al paso anterior; VoiceOver lo lee."
    )
}

#if DEBUG
#Preview("Variantes Figma") {
    VStack(spacing: Spacing.xxl) {
        ForEach(OnboardingStep.allCases, id: \.self) { step in
            OnboardingTopBar(step: step) {}
                .background(step == .welcome ? Color.black : .bgSecondary)
        }
    }
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    VStack(spacing: Spacing.xxl) {
        ForEach(OnboardingStep.allCases, id: \.self) { step in
            OnboardingTopBar(step: step) {}
        }
    }
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}
#endif
