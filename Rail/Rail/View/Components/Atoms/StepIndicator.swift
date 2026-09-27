import SwiftUI

struct StepIndicator: View {
    private let count: Int
    private let current: Int

    private static let dot: CGFloat = Spacing.sm
    private static let activeWidth: CGFloat = Spacing.xxl

    init(count: Int, current: Int) {
        self.count = count
        self.current = current
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    .frame(width: index == current ? Self.activeWidth : Self.dot, height: Self.dot)
            }
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    VStack(spacing: Spacing.xxl) {
        ForEach(0..<4, id: \.self) { current in
            StepIndicator(count: 4, current: current)
        }
        StepIndicator(count: 4, current: 1)
            .foregroundStyle(.white)
            .tint(.white)
            .padding(Spacing.lg)
            .background(.black)
    }
    .foregroundStyle(.textSecondary)
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}

#Preview("Animación") {
    @Previewable @State var current = 0

    StepIndicator(count: 4, current: current)
        .foregroundStyle(.textSecondary)
        .animation(.smooth, value: current)
        .padding(Spacing.xxl)
        .background(.bgSecondary)
        .onTapGesture { current = (current + 1) % 4 }
}
#endif
