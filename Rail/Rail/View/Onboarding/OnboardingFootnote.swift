import SwiftUI

struct OnboardingFootnote: View {
    private let text: LocalizedStringResource

    init(_ text: LocalizedStringResource) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
    }
}
