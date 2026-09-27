import SwiftUI

enum OnboardingLayout {
    static let columnWidth: CGFloat = 540
    static let regularTopInset: CGFloat = 64
}

extension View {
    func onboardingColumn() -> some View {
        padding(.horizontal, ScreenLayout.margin)
            .frame(maxWidth: OnboardingLayout.columnWidth)
            .frame(maxWidth: .infinity)
    }
}
