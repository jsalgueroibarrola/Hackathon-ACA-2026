import SwiftUI

struct FocalFill: Layout {
    let focus: CGRect

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews.forEach { subview in
            let frame = Self.frame(
                in: bounds.size,
                content: subview.sizeThatFits(.unspecified),
                focus: focus
            )
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    static func frame(
        in container: CGSize,
        content: CGSize,
        focus: CGRect
    ) -> CGRect {
        guard content.width > 0, content.height > 0, focus.width > 0, focus.height > 0 else {
            return CGRect(origin: .zero, size: container)
        }
        let fill = max(container.width / content.width, container.height / content.height)
        let fit = min(
            container.width / (focus.width * content.width),
            container.height / (focus.height * content.height)
        )
        let scale = max(fill, fit)
        let size = CGSize(width: content.width * scale, height: content.height * scale)
        return CGRect(
            origin: CGPoint(
                x: offset(centering: focus.midX, of: size.width, in: container.width),
                y: offset(centering: focus.midY, of: size.height, in: container.height)
            ),
            size: size
        )
    }

    private static func offset(
        centering unit: CGFloat,
        of length: CGFloat,
        in available: CGFloat
    ) -> CGFloat {
        min(max(available / 2 - unit * length, min(available - length, 0)), 0)
    }
}
