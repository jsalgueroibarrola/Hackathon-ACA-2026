import SwiftUI

struct RefreshBanner: View {
    let lastFetchedAt: Date?

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.statusWarning)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.statusWarningText)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .glassEffect(.regular.tint(.statusWarningBg), in: .capsule)
        .padding(.bottom, Spacing.sm)
    }

    private var message: LocalizedStringResource {
        lastFetchedAt.map {
            LocalizedStringResource(
                "Última actualización: \($0, format: .relative(presentation: .named))",
                comment: "Banner inferior. La variable es la antigüedad de los datos en formato relativo, por ejemplo «ayer» o «hace 2 horas»."
            )
        }
            ?? LocalizedStringResource(
                "No se han podido actualizar los horarios",
                comment: "Aviso del banner inferior cuando falla la actualización y no se conoce la fecha de la última descarga."
            )
    }
}

#if DEBUG
#Preview {
    RefreshBanner(lastFetchedAt: .now.addingTimeInterval(-90_000))
}
#endif
