import SwiftUI

struct DataLoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .controlSize(.large)

            Text(
                "Descargando horarios",
                comment: "Título de la pantalla de carga mientras se descargan los datos de la red."
            )
            .font(.headline)

            Text(
                "Solo ocurre la primera vez o cuando los datos caducan.",
                comment: "Texto secundario de la pantalla de carga; explica por qué hay que esperar."
            )
            .font(.subheadline)
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    DataLoadingView()
}
#endif
