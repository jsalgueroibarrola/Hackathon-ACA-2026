import SwiftUI

extension View {
    func cardSurface() -> some View {
        padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.bgPrimary, in: .rect(cornerRadius: Radius.md, style: .continuous))
    }
}
