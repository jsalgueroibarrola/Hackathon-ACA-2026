import SwiftUI

struct AlertBanner: View {
    private let severity: IncidentSeverity
    private let title: String
    private let message: String?
    private let onDismiss: (() -> Void)?
    private let onTap: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .subheadline) private var closeSide: CGFloat =
        Size.buttonSm

    init(
        _ severity: IncidentSeverity,
        title: String,
        message: String? = nil,
        onDismiss: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.severity = severity
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
        self.onTap = onTap
    }

    var body: some View {
        HStack(alignment: rowAlignment, spacing: Spacing.md) {
            tappableContent
            closeButton
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            severity.background,
            in: .rect(cornerRadius: Radius.lg, style: .continuous)
        )
    }

    @ViewBuilder
    private var tappableContent: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
        } else {
            content
                .accessibilityElement(children: .combine)
        }
    }

    private var content: some View {
        HStack(alignment: rowAlignment, spacing: Spacing.md) {
            Image(systemName: severity.symbol)
                .font(.title3)
                .foregroundStyle(severity.tint)
                .accessibilityHidden(true)
            texts
            if onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(severity.tint)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(.rect)
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(verbatim: title)
                .font(.subheadlineEmphasized)
            if let message {
                Text(verbatim: message)
                    .font(.footnote)
            }
        }
        .foregroundStyle(severity.foreground)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var closeButton: some View {
        if let onDismiss {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.semibold))
                    .frame(width: closeSide, height: closeSide)
            }
            .buttonStyle(.plain)
            .foregroundStyle(severity.tint)
            .contentShape(.rect.inset(by: -touchInset))
            .accessibilityLabel(Self.dismissLabel)
        }
    }

    private var rowAlignment: VerticalAlignment {
        dynamicTypeSize.isAccessibilitySize ? .top : .center
    }

    private var touchInset: CGFloat {
        max(0, (Size.touchMin - closeSide) / 2)
    }

    private static let dismissLabel = LocalizedStringResource(
        "Descartar aviso",
        comment: "Acción del botón que cierra una banda de aviso de incidencia"
    )
}

#if DEBUG
#Preview("Variantes Figma") {
    VStack(spacing: Spacing.md) {
        ForEach(IncidentSeverity.allCases, id: \.self) { severity in
            AlertBanner(
                severity,
                title: "Retrasos en la línea C-1",
                message:
                    "Demoras de hasta 10 min entre Torremolinos y Fuengirola.",
                onTap: {}
            )
        }
    }
    .padding(ScreenLayout.margin)
    .background(.bgPrimary)
}

#Preview("Chevron y cierre") {
    VStack(spacing: Spacing.md) {
        AlertBanner(
            .info,
            title: "Retrasos en la línea C-1",
            message: "Demoras de hasta 10 min entre Torremolinos y Fuengirola."
        )
        AlertBanner(
            .warning,
            title: "Retrasos en la línea C-1",
            message: "Demoras de hasta 10 min entre Torremolinos y Fuengirola.",
            onTap: {}
        )
        AlertBanner(
            .critical,
            title: "Servicio interrumpido",
            message: "Sin circulación entre Málaga Centro y Los Álamos.",
            onDismiss: {}
        )
        AlertBanner(
            .resolved,
            title: "Incidencia resuelta",
            onDismiss: {},
            onTap: {}
        )
    }
    .padding(ScreenLayout.margin)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    VStack(spacing: Spacing.md) {
        ForEach(IncidentSeverity.allCases, id: \.self) { severity in
            AlertBanner(
                severity,
                title: "Retrasos en la línea C-1",
                message:
                    "Demoras de hasta 10 min entre Torremolinos y Fuengirola.",
                onDismiss: {},
                onTap: {}
            )
        }
    }
    .padding(ScreenLayout.margin)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            AlertBanner(
                .warning,
                title: "Retrasos en la línea C-1",
                message:
                    "Demoras de hasta 10 min entre Torremolinos y Fuengirola.",
                onDismiss: {},
                onTap: {}
            )
            AlertBanner(.resolved, title: "Incidencia resuelta", onTap: {})
        }
        .padding(ScreenLayout.margin)
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
#endif
