import SwiftUI

struct IncidentCard<Action: View>: View {
    private let severity: IncidentSeverity
    private let label: LocalizedStringResource?
    private let title: String
    private let description: String?
    private let time: String?
    private let lines: [LineMark]
    private let action: Action

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        _ severity: IncidentSeverity,
        label: LocalizedStringResource? = nil,
        title: String,
        description: String? = nil,
        time: String?,
        lines: [LineMark],
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.severity = severity
        self.label = label
        self.title = title
        self.description = description
        self.time = time
        self.lines = lines
        self.action = action()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            header
            texts
            footer
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(
            .bgElevated,
            in: .rect(cornerRadius: Radius.xl, style: .continuous)
        )
        .elevation(.card)
    }

    @ViewBuilder
    private var header: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                SeverityBadge(severity, label: label)
                timeText
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: Spacing.sm) {
                SeverityBadge(severity, label: label)
                Spacer(minLength: Spacing.sm)
                timeText
            }
        }
    }

    @ViewBuilder
    private var timeText: some View {
        if let time {
            Text(verbatim: time)
                .font(.caption)
                .foregroundStyle(.textTertiary)
                .lineLimit(1)
                .fixedSize()
        }
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(verbatim: title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
            if let description {
                Text(verbatim: description)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var footer: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                badges
                actionButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: Spacing.sm) {
                badges
                Spacer(minLength: Spacing.sm)
                actionButton
            }
        }
    }

    private var badges: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(lines) { line in
                LineBadge(line.id, color: line.color)
            }
        }
    }

    private var actionButton: some View {
        action
            .buttonStyle(.rail(.borderless))
            .controlSize(.small)
    }
}

#Preview("Variantes Figma") {
    let c1 = Color(hex: "DA291C")

    ScrollView {
        VStack(spacing: ScreenLayout.gutter) {
            ForEach(IncidentSeverity.allCases, id: \.self) { severity in
                IncidentCard(
                    severity,
                    title: "Retrasos en la línea C-1",
                    description:
                        "Demoras de hasta 10 min entre Torremolinos y Fuengirola por una incidencia técnica. Se recomienda prever tiempo adicional.",
                    time: "Hace 12 min",
                    lines: [.init("C-1", color: c1)]
                ) {
                    Button("Ver detalles") {}
                }
            }
        }
        .padding(ScreenLayout.margin)
    }
    .background(.bgSecondary)
}

#Preview("Sin descripción ni acción") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: ScreenLayout.gutter) {
        IncidentCard(
            .resolved,
            title: "Incidencia resuelta",
            time: "Hace 2 h",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
        )
        IncidentCard(
            .critical,
            title: "Servicio interrumpido entre Málaga Centro y Los Álamos",
            description:
                "Sin circulación por una avería en la catenaria. Servicio alternativo por carretera.",
            time: "Hace 3 min",
            lines: [.init("C-1", color: c1)]
        ) {
            Button("Ver detalles") {}
        }
    }
    .padding(ScreenLayout.margin)
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    let c1 = Color(hex: "DA291C")

    ScrollView {
        VStack(spacing: ScreenLayout.gutter) {
            ForEach(IncidentSeverity.allCases, id: \.self) { severity in
                IncidentCard(
                    severity,
                    title: "Retrasos en la línea C-1",
                    description:
                        "Demoras de hasta 10 min entre Torremolinos y Fuengirola por una incidencia técnica.",
                    time: "Hace 12 min",
                    lines: [.init("C-1", color: c1)]
                ) {
                    Button("Ver detalles") {}
                }
            }
        }
        .padding(ScreenLayout.margin)
    }
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    ScrollView {
        IncidentCard(
            .warning,
            title: "Retrasos en la línea C-1",
            description:
                "Demoras de hasta 10 min entre Torremolinos y Fuengirola por una incidencia técnica.",
            time: "Hace 12 min",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
        ) {
            Button("Ver detalles") {}
        }
        .padding(ScreenLayout.margin)
    }
    .background(.bgSecondary)
    .dynamicTypeSize(.accessibility2)
}
