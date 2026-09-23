import SwiftUI

private struct ViewportFit: Layout {
    let height: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        subviews.first?.sizeThatFits(
            ProposedViewSize(width: proposal.width, height: height)
        ) ?? .zero
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews.first?.place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bounds.width, height: height)
        )
    }
}

private struct ViewportFitModifier: ViewModifier {
    @State private var height: CGFloat = 0

    func body(content: Content) -> some View {
        ViewportFit(height: height) { content }
            .background {
                Color.clear
                    .containerRelativeFrame(.vertical)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height = $0 }
            }
    }
}

extension View {
    func fitsScrollViewport() -> some View {
        modifier(ViewportFitModifier())
    }
}
