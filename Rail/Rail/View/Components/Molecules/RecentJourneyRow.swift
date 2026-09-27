import SwiftUI

struct RecentJourneyRow: View {
    private let item: RecentJourneyItem
    private let showsSeparator: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var iconBox: CGFloat = Size.iconLg

    private static let minHeight: CGFloat = 60

    init(_ item: RecentJourneyItem, showsSeparator: Bool = true) {
        self.item = item
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.subheadlineEmphasized)
                .foregroundStyle(.brandPrimary)
                .frame(width: iconBox, height: iconBox)
                .background(.brandPrimarySubtle, in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                route
                Text(item.lastSearchedAt, format: .relative(presentation: .named))
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.interactiveIconSubtle)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.vertical, Spacing.sm)
        .frame(minHeight: Self.minHeight)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(.interactiveSeparator)
                    .frame(height: Border.hairline)
                    .padding(.leading, ScreenLayout.margin)
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text(
                "De \(item.originName) a \(item.destinationName)",
                comment: "Trayectos: lectura de VoiceOver de una búsqueda reciente; estación de origen y de destino."
            )
        )
    }

    @ViewBuilder
    private var route: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                name(item.originName)
                HStack(spacing: Spacing.xs) {
                    arrow
                    name(item.destinationName)
                }
            }
        } else {
            HStack(spacing: Spacing.xs) {
                name(item.originName)
                arrow
                name(item.destinationName)
            }
        }
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.textTertiary)
    }

    private func name(_ text: String) -> some View {
        Text(verbatim: text)
            .font(.headline)
            .foregroundStyle(.textPrimary)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        RecentJourneyRow(
            RecentJourneyItem(
                originID: "54413",
                destinationID: "54100",
                originName: "Málaga-Centro Alameda",
                destinationName: "Fuengirola",
                lastSearchedAt: .now.addingTimeInterval(-600)
            )
        )
        RecentJourneyRow(
            RecentJourneyItem(
                originID: "54100",
                destinationID: "54503",
                originName: "Fuengirola",
                destinationName: "Álora",
                lastSearchedAt: .now.addingTimeInterval(-3 * 86_400)
            ),
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}
#endif
