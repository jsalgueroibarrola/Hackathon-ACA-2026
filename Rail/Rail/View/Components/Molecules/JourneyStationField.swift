import SwiftUI

struct JourneyStationField: View {
    private let title: LocalizedStringResource
    private let stationName: String?
    private let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ title: LocalizedStringResource, stationName: String?, action: @escaping () -> Void) {
        self.title = title
        self.stationName = stationName
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            layout {
                Text(title)
                    .font(.bodyEmphasized)
                    .foregroundStyle(.textPrimary)
                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: Spacing.sm)
                }
                HStack(spacing: Spacing.sm) {
                    value
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(stationName == nil ? .textTertiary : .brandPrimary)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.stationField)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(stationName.map { Text(verbatim: $0) } ?? Text(Self.placeholder))
        .accessibilityHint(Text(Self.hint))
    }

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xs))
            : AnyLayout(HStackLayout(spacing: Spacing.sm))
    }

    private var value: some View {
        Group {
            if let stationName {
                Text(verbatim: stationName)
                    .foregroundStyle(.brandPrimary)
            } else {
                Text(Self.placeholder)
                    .foregroundStyle(.textTertiary)
            }
        }
        .font(.bodyMedium)
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
        .multilineTextAlignment(.trailing)
    }

    private static let placeholder = LocalizedStringResource(
        "Elegir",
        comment: "Trayectos: texto del campo de origen o destino cuando todavía no se ha elegido estación."
    )

    private static let hint = LocalizedStringResource(
        "Abre la lista de estaciones.",
        comment: "Trayectos: indicación de VoiceOver del campo de origen o destino."
    )
}

#if DEBUG
#Preview {
    VStack(spacing: Spacing.md) {
        JourneyStationField("Origen", stationName: "Málaga-Centro Alameda") {}
        JourneyStationField("Destino", stationName: nil) {}
    }
    .cardSurface()
    .padding(ScreenLayout.margin)
    .background(.bgSecondary)
}

#Preview("Dynamic Type") {
    VStack(spacing: Spacing.md) {
        JourneyStationField("Origen", stationName: "Benalmádena-Arroyo de la Miel") {}
        JourneyStationField("Destino", stationName: nil) {}
    }
    .cardSurface()
    .padding(ScreenLayout.margin)
    .background(.bgSecondary)
    .dynamicTypeSize(.accessibility2)
}
#endif
