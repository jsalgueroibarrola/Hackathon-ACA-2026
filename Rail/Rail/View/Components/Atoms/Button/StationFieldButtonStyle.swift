import SwiftUI

struct StationFieldButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var height: CGFloat = Size.buttonLg

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? .textPrimary : .textDisabled)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(.bgSecondary, in: .rect(cornerRadius: Radius.lg, style: .continuous))
            .overlay {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .fill(.interactivePressedOverlay)
                }
            }
            .contentShape(.rect(cornerRadius: Radius.lg, style: .continuous))
    }
}

extension ButtonStyle where Self == StationFieldButtonStyle {
    static var stationField: Self {
        StationFieldButtonStyle()
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Spacing.md) {
        Button {} label: {
            HStack {
                Text(verbatim: "Origen")
                Spacer()
                Text(verbatim: "Málaga-Centro Alameda")
                    .foregroundStyle(.brandPrimary)
            }
        }
        Button {} label: {
            Text(verbatim: "Destino")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(true)
    }
    .buttonStyle(.stationField)
    .cardSurface()
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}
#endif
