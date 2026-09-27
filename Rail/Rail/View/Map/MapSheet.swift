import SwiftUI

enum MapSheetPart: Sendable {
    case header
    case content
}

struct MapSheetActions {
    let drag: (VerticalDragEvent) -> Void
    let close: () -> Void
    let measure: (MapSheetPart, CGFloat) -> Void
}

struct MapSheet<Header: View, Content: View>: View {
    private let bodyScrolls: Bool
    private let actions: MapSheetActions
    private let header: Header
    private let content: Content

    init(
        bodyScrolls: Bool,
        actions: MapSheetActions,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.bodyScrolls = bodyScrolls
        self.actions = actions
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    actions.measure(.content, height)
                }
        }
        .scrollDisabled(!bodyScrolls)
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaBar(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                MapSheetGrabber()
                header
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                actions.measure(.header, height)
            }
            .onVerticalDrag(isEnabled: bodyScrolls, perform: actions.drag)
        }
        .contentShape(.rect)
        .onVerticalDrag(isEnabled: !bodyScrolls, perform: actions.drag)
        .accessibilityAction(.escape, actions.close)
    }
}

private struct MapSheetGrabber: View {
    var body: some View {
        Capsule()
            .fill(.textTertiary)
            .frame(width: Self.width, height: Self.height)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.sm)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    private static let width: CGFloat = 36
    private static let height: CGFloat = 5
}

extension View {
    func mapSheetSurface() -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: Radius.xl))
    }
}
