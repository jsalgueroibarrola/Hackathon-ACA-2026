import SwiftUI

extension View {
    func measure(_ name: String) -> some View {
        onGeometryChange(for: CGSize.self) { $0.size } action: { size in
            print("MEASURE \(name) \(size.width)x\(size.height)")
        }
    }
}
