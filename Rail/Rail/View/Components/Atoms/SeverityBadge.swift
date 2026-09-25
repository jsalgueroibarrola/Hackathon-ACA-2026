import SwiftUI

struct SeverityBadge: View {
    private let severity: IncidentSeverity
    private let label: LocalizedStringResource?
    private let showsIcon: Bool
    @ScaledMetric(relativeTo: .caption) private var height: CGFloat = Size.chip

    init(
        _ severity: IncidentSeverity,
        label: LocalizedStringResource? = nil,
        showsIcon: Bool = true
    ) {
        self.severity = severity
        self.label = label
        self.showsIcon = showsIcon
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if showsIcon {
                Image(systemName: severity.symbol)
                    .font(.caption)
                    .accessibilityHidden(true)
            }
            Text(label ?? severity.label)
                .font(.captionEmphasized)
                .tracking(Tracking.wide)
                .lineLimit(1)
        }
        .foregroundStyle(severity.foreground)
        .padding(.horizontal, Spacing.sm)
        .frame(minHeight: height)
        .background(severity.background, in: .capsule)
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label ?? severity.label)
    }

}

#Preview("Variantes Figma") {
    VStack(spacing: Spacing.xxl) {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.lg) {
                SeverityBadge(.info, label: "Incidencia")
                SeverityBadge(.warning, label: "Incidencia")
                SeverityBadge(.critical, label: "Incidencia")
                SeverityBadge(.resolved, label: "Incidencia")
            }
        }
        HStack(spacing: Spacing.lg) {
            SeverityBadge(.info, label: "Incidencia", showsIcon: false)
            SeverityBadge(.warning, label: "Incidencia", showsIcon: false)
            SeverityBadge(.critical, label: "Incidencia", showsIcon: false)
            SeverityBadge(.resolved, label: "Incidencia", showsIcon: false)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Etiqueta por gravedad") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        ForEach(IncidentSeverity.allCases, id: \.self) { severity in
            SeverityBadge(severity)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("En contexto") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        SeverityBadge(.info, label: "Obras en Los Boliches")
        SeverityBadge(.warning, label: "Retrasos de hasta 10 min")
        SeverityBadge(.critical, label: "Servicio interrumpido")
        SeverityBadge(.resolved, label: "Incidencia resuelta")
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    VStack(spacing: Spacing.md) {
        ForEach(IncidentSeverity.allCases, id: \.self) { severity in
            SeverityBadge(severity, label: "Incidencia")
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    VStack(spacing: Spacing.md) {
        SeverityBadge(.warning, label: "Retrasos")
        SeverityBadge(.critical, label: "Servicio interrumpido")
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
