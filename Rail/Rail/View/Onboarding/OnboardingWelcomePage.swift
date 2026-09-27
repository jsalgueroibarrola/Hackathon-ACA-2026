import SwiftData
import SwiftUI

struct OnboardingWelcomePage: View {
    private let hasDownloadFailed: Bool
    private let onContinue: () -> Void

    @Query private var lines: [Line]

    private static let headerSpacing: CGFloat = 6

    init(hasDownloadFailed: Bool, onContinue: @escaping () -> Void) {
        self.hasDownloadFailed = hasDownloadFailed
        self.onContinue = onContinue
    }

    private var rows: [LineRow] {
        lines.sortedByID.map { LineRow(id: $0.id, name: $0.name, color: $0.tint.base) }
    }

    var body: some View {
        OnboardingFeaturePage(
            placement: .fullBleed,
            actions: OnboardingActionBar(primary: .start(onContinue))
        ) {
            OnboardingArtwork(.welcome)
        } content: {
            VStack(spacing: Spacing.xxxxxl) {
                OnboardingHeader(
                    Self.title,
                    message: Self.message,
                    spacing: Self.headerSpacing,
                    messageFont: .headline
                )
                network
            }
        }
    }

    private var network: some View {
        VStack(spacing: Spacing.lg) {
            lineList
            OnboardingFootnote(Self.exclusions)
        }
    }

    @ViewBuilder
    private var lineList: some View {
        let rows = rows
        if !rows.isEmpty {
            lineRows(rows)
                .transition(.opacity)
        } else if !hasDownloadFailed {
            lineRows(LineRow.placeholders)
                .redacted(reason: .placeholder)
                .accessibilityHidden(true)
        }
    }

    private func lineRows(_ rows: [LineRow]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(rows) { row in
                HStack(spacing: Spacing.md) {
                    LineBadge(row.id, color: row.color, scale: .large)
                    Text(verbatim: row.name)
                        .font(.bodyEmphasized)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .animation(.smooth, value: rows.map(\.id))
    }

    private static let title = LocalizedStringResource(
        "¡Bienvenido a Rail!",
        comment: "Bienvenida, paso 1: título de la primera pantalla."
    )

    private static let message = LocalizedStringResource(
        "Rail funciona con los trenes de Cercanías de Málaga.",
        comment: "Bienvenida, paso 1: subtítulo que explica qué red de trenes cubre la app."
    )

    private static let exclusions = LocalizedStringResource(
        "No incluye trenes AVE ni de Media Distancia.",
        comment: "Bienvenida, paso 1: nota bajo la lista de líneas. Mantén «AVE» y «Media Distancia» sin traducir: son nombres de servicios de Renfe."
    )
}

private struct LineRow: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color

    static let placeholders = [
        LineRow(id: "C1", name: "Málaga-Centro Alameda – Fuengirola", color: .fillTertiary),
        LineRow(id: "C2", name: "Málaga-Centro Alameda – Álora", color: .fillTertiary),
    ]
}

#if DEBUG
#Preview("Variantes Figma", traits: .nextTrainsSampleData) {
    OnboardingWelcomePage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
}

#Preview("Descargando") {
    OnboardingWelcomePage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .modelContainer(for: RailSchema.models, inMemory: true)
}

#Preview("Modo oscuro", traits: .nextTrainsSampleData) {
    OnboardingWelcomePage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .preferredColorScheme(.dark)
}
#endif
