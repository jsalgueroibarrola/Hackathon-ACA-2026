import SwiftUI

extension View {
    func onVerticalDrag(
        isEnabled: Bool = true,
        perform action: @escaping (VerticalDragEvent) -> Void
    ) -> some View {
        modifier(VerticalDragModifier(isEnabled: isEnabled, action: action))
    }
}

private enum VerticalDragLock: Equatable {
    case vertical(start: CGFloat)
    case rejected
}

private struct VerticalDragModifier: ViewModifier {
    let isEnabled: Bool
    let action: (VerticalDragEvent) -> Void

    @State private var lock: VerticalDragLock?
    @GestureState private var isActive = false

    func body(content: Content) -> some View {
        content
            .gesture(drag, isEnabled: isEnabled)
            .onChange(of: isActive) { _, isActive in
                guard !isActive else { return }
                let released = lock
                lock = nil
                guard case .vertical = released else { return }
                action(.cancelled)
            }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: Self.minimumDistance, coordinateSpace: .global)
            .updating($isActive) { _, isActive, _ in
                isActive = true
            }
            .onChanged(changed)
            .onEnded(ended)
    }

    private func changed(_ value: DragGesture.Value) {
        let current =
            lock
            ?? (VerticalDragResolver.accepts(value.translation)
                ? .vertical(start: value.translation.height) : .rejected)
        lock = current
        guard case .vertical(let start) = current else { return }
        action(.changed(value.translation.height - start))
    }

    private func ended(_ value: DragGesture.Value) {
        defer { lock = nil }
        guard case .vertical(let start) = lock else { return }
        action(
            .ended(
                translation: value.translation.height - start,
                predicted: value.predictedEndTranslation.height - start
            )
        )
    }

    private static let minimumDistance: CGFloat = 12
}
