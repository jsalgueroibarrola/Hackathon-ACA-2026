import SwiftUI

struct OnboardingHeader: View {
    private let title: LocalizedStringResource
    private let message: LocalizedStringResource
    private let spacing: CGFloat
    private let messageFont: Font

    init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource,
        spacing: CGFloat = Spacing.sm,
        messageFont: Font = .body
    ) {
        self.title = title
        self.message = message
        self.spacing = spacing
        self.messageFont = messageFont
    }

    var body: some View {
        VStack(spacing: spacing) {
            Text(title)
                .font(.titleEmphasized)
                .tracking(Tracking.tight)
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(messageFont)
                .foregroundStyle(.textSecondary)
                .padding(.horizontal, Spacing.lg)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }
}
