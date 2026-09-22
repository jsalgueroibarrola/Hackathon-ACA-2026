import SwiftUI

struct IncidentRow: View {
    private let severity: IncidentSeverity
    private let title: String
    private let subtitle: String
    private let lines: [LineMark]
    private let showsSeparator: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .headline) private var tileSide: CGFloat =
        Self.tile

    private static let tile: CGFloat = 36
    private static let minHeight: CGFloat = 60

    init(
        _ severity: IncidentSeverity,
        title: String,
        subtitle: String,
        lines: [LineMark],
        showsSeparator: Bool = true
    ) {
        self.severity = severity
        self.title = title
        self.subtitle = subtitle
        self.lines = lines
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        HStack(alignment: rowAlignment, spacing: Spacing.md) {
            iconTile
            content
            chevron
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.vertical, Spacing.md)
        .frame(minHeight: Self.minHeight)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(.interactiveSeparator)
                    .frame(height: Border.hairline)
                    .padding(.leading, ScreenLayout.margin)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var iconTile: some View {
        Image(systemName: severity.symbol)
            .font(.title3)
            .foregroundStyle(severity.tint)
            .frame(width: tileSide, height: tileSide)
            .background(
                severity.background,
                in: .rect(cornerRadius: Radius.md, style: .continuous)
            )
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                texts
                badges
            }
        } else {
            HStack(spacing: Spacing.md) {
                texts
                badges
            }
        }
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(verbatim: title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(verbatim: subtitle)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .lineLimit(2)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var badges: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(lines) { line in
                LineBadge(line.id, color: line.color)
            }
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.interactiveIconSubtle)
            .accessibilityHidden(true)
    }

    private var rowAlignment: VerticalAlignment {
        dynamicTypeSize.isAccessibilitySize ? .top : .center
    }

    private var accessibilityLabel: LocalizedStringResource {
        LocalizedStringResource(
            "\(severity.label), \(title), \(subtitle), \(lines.map(\.id).formatted(.list(type: .and)))",
            comment:
                "Lectura de VoiceOver de una fila de incidencia: gravedad, título, detalle y líneas afectadas"
        )
    }
}

#Preview("Variantes Figma") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")
    let combinaciones: [[LineMark]] = [
        [.init("C-1", color: c1)],
        [.init("C-2", color: c2)],
        [.init("C-1", color: c1), .init("C-2", color: c2)],
    ]

    ScrollView {
        VStack(spacing: 0) {
            ForEach(IncidentSeverity.allCases, id: \.self) { severity in
                ForEach(Array(combinaciones.enumerated()), id: \.offset) {
                    indice,
                    lineas in
                    IncidentRow(
                        severity,
                        title: "Retrasos en la C-1",
                        subtitle: "Actualizado 10:32 · Hasta 10 min",
                        lines: lineas,
                        showsSeparator: !(severity == .resolved && indice == 2)
                    )
                }
            }
        }
    }
    .background(.bgPrimary)
}

#Preview("Títulos largos") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        IncidentRow(
            .warning,
            title: "Retrasos entre Torremolinos y Fuengirola por obras",
            subtitle: "Actualizado 10:32 · Hasta 10 min",
            lines: [.init("C-1", color: c1)]
        )
        IncidentRow(
            .critical,
            title: "Servicio interrumpido",
            subtitle:
                "Actualizado 09:58 · Entre Málaga María Zambrano y Los Álamos",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    let c1 = Color(hex: "DA291C")

    VStack(spacing: 0) {
        ForEach(IncidentSeverity.allCases, id: \.self) { severity in
            IncidentRow(
                severity,
                title: "Retrasos en la C-1",
                subtitle: "Actualizado 10:32 · Hasta 10 min",
                lines: [.init("C-1", color: c1)],
                showsSeparator: severity != .resolved
            )
        }
    }
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    ScrollView {
        VStack(spacing: 0) {
            IncidentRow(
                .warning,
                title: "Retrasos en la C-1",
                subtitle: "Actualizado 10:32 · Hasta 10 min",
                lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
            )
            IncidentRow(
                .resolved,
                title: "Incidencia resuelta",
                subtitle: "Actualizado 11:05",
                lines: [.init("C-2", color: c2)],
                showsSeparator: false
            )
        }
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
