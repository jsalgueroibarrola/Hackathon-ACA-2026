import SwiftUI

struct CardMessage: View {
    enum Icon {
        case symbol(String, tint: Color)
        case progress
    }

    enum Prominence {
        case regular
        case compact
    }

    struct Action {
        let title: LocalizedStringResource
        let perform: () -> Void
    }

    private let title: LocalizedStringResource
    private let message: LocalizedStringResource?
    private let icon: Icon
    private let prominence: Prominence
    private let primary: Action?
    private let secondary: Action?
    @ScaledMetric private var iconSize: CGFloat

    init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        icon: Icon,
        prominence: Prominence = .regular,
        primary: Action? = nil,
        secondary: Action? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.prominence = prominence
        self.primary = primary
        self.secondary = secondary
        _iconSize = ScaledMetric(
            wrappedValue: prominence.iconSize,
            relativeTo: .title
        )
    }

    var body: some View {
        VStack(spacing: prominence.spacing) {
            iconView
            texts
            actions
        }
        .frame(maxWidth: .infinity)
        .padding(prominence.padding)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .symbol(let name, let tint):
            Image(systemName: name)
                .font(.system(size: iconSize))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        case .progress:
            ProgressView()
                .controlSize(.large)
        }
    }

    private var texts: some View {
        VStack(spacing: prominence.spacing) {
            Text(title)
                .font(prominence.titleFont)
                .foregroundStyle(.textPrimary)
            if let message {
                Text(message)
                    .font(prominence.messageFont)
                    .foregroundStyle(.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var actions: some View {
        if primary != nil || secondary != nil {
            VStack(spacing: prominence.spacing) {
                if let primary {
                    Button(action: primary.perform) {
                        Text(primary.title)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.railGlass(.tinted))
                }
                if let secondary {
                    Button(secondary.title, action: secondary.perform)
                        .buttonStyle(.rail(.borderless))
                }
            }
            .padding(.top, Spacing.xs + prominence.spacing)
        }
    }
}

extension CardMessage.Prominence {
    fileprivate var padding: EdgeInsets {
        switch self {
        case .regular:
            EdgeInsets(
                top: Spacing.md,
                leading: Spacing.sm,
                bottom: Spacing.xs,
                trailing: Spacing.sm
            )
        case .compact:
            EdgeInsets(
                top: Spacing.sm,
                leading: Spacing.none,
                bottom: Spacing.md,
                trailing: Spacing.none
            )
        }
    }

    fileprivate var spacing: CGFloat {
        switch self {
        case .regular: Spacing.sm
        case .compact: Spacing.xs
        }
    }

    fileprivate var iconSize: CGFloat {
        switch self {
        case .regular: 30
        case .compact: 26
        }
    }

    fileprivate var titleFont: Font {
        switch self {
        case .regular: .headline
        case .compact: .subheadlineEmphasized
        }
    }

    fileprivate var messageFont: Font {
        switch self {
        case .regular: .subheadline
        case .compact: .footnote
        }
    }
}

#if DEBUG
private struct CardMessageSamples: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            CardMessage(
                "Activa la ubicación",
                message:
                    "Verás tu estación más cercana y sus próximos trenes nada más abrir Rail.",
                icon: .symbol("location.fill", tint: .brandPrimary),
                primary: .init(title: "Permitir ubicación") {},
                secondary: .init(title: "Elegir estación") {}
            )
            CardMessage(
                "Elige tu estación habitual",
                message:
                    "No tenemos permiso para usar tu ubicación. Elige la estación que más usas y la tendrás siempre aquí.",
                icon: .symbol("location.fill", tint: .textTertiary),
                primary: .init(title: "Elegir estación") {},
                secondary: .init(title: "Abrir Ajustes") {}
            )
            CardMessage(
                "No hemos podido ubicarte",
                message:
                    "Puede pasar bajo tierra o en interiores. Inténtalo otra vez o elige tu estación.",
                icon: .symbol(
                    "exclamationmark.circle.fill",
                    tint: .statusWarning
                ),
                primary: .init(title: "Reintentar") {},
                secondary: .init(title: "Elegir estación") {}
            )
            CardMessage(
                "No hay estaciones de Cercanías cerca",
                message:
                    "La más próxima, Álora, está a 38 km. Puedes verla en el mapa o elegir tu estación habitual.",
                icon: .symbol("magnifyingglass", tint: .textTertiary),
                primary: .init(title: "Ver en el mapa") {},
                secondary: .init(title: "Elegir estación") {}
            )
            CardMessage(
                "Buscando tu ubicación…",
                icon: .progress,
                secondary: .init(title: "Elegir estación") {}
            )
            CardMessage(
                "No quedan trenes hoy",
                message: "Primera salida mañana a las 05:40",
                icon: .symbol("clock", tint: .textTertiary),
                prominence: .compact
            )
        }
        .frame(width: 336)
        .padding(ScreenLayout.margin)
        .background(.bgPrimary)
    }
}

#Preview("Variantes Figma") {
    ScrollView {
        CardMessageSamples()
    }
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    ScrollView {
        CardMessageSamples()
    }
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    ScrollView {
        CardMessageSamples()
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
#endif
