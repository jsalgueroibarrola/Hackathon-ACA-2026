import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        Image(.launchLogo)
            .accessibilityHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bgSecondary)
    }
}

#if DEBUG
#Preview {
    LaunchScreenView()
}

#Preview("Modo oscuro") {
    LaunchScreenView()
        .preferredColorScheme(.dark)
}
#endif
