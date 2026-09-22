import SwiftUI

struct LineBadge: View {
    enum Scale: CaseIterable {
        case small
        case large
    }

    private static let minWidth: CGFloat = 40

    private let title: String
    private let color: Color
    private let scale: Scale
    @ScaledMetric private var height: CGFloat
    @ScaledMetric private var minWidth: CGFloat

    init(_ title: String, color: Color, scale: Scale = .small) {
        self.title = title
        self.color = color
        self.scale = scale
        _height = ScaledMetric(wrappedValue: scale.height, relativeTo: scale.textStyle)
        _minWidth = ScaledMetric(wrappedValue: Self.minWidth, relativeTo: scale.textStyle)
    }

    var body: some View {
        Text(verbatim: title)
            .font(scale.font)
            .tracking(scale.tracking)
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, scale.horizontalPadding)
            .frame(minWidth: minWidth, minHeight: height)
            .background(color, in: .rect(cornerRadius: scale.cornerRadius, style: .continuous))
            .fixedSize()
    }
}

extension LineBadge.Scale {
    fileprivate var height: CGFloat {
        switch self {
        case .small: Size.lineBadgeSm
        case .large: Size.lineBadge
        }
    }

    fileprivate var horizontalPadding: CGFloat {
        switch self {
        case .small: Spacing.sm
        case .large: Spacing.md
        }
    }

    fileprivate var cornerRadius: CGFloat {
        switch self {
        case .small: Radius.sm
        case .large: Radius.md
        }
    }

    fileprivate var textStyle: Font.TextStyle {
        switch self {
        case .small: .caption
        case .large: .headline
        }
    }

    fileprivate var font: Font {
        switch self {
        case .small: .captionEmphasized
        case .large: .headline
        }
    }

    fileprivate var tracking: CGFloat {
        switch self {
        case .small: Tracking.wide
        case .large: 0
        }
    }
}

#Preview("Variantes Figma") {
    Grid(horizontalSpacing: Spacing.xxxxl, verticalSpacing: Spacing.xxl) {
        GridRow {
            LineBadge("C-1", color: Color(hex: "DA291C"))
            LineBadge("C-1", color: Color(hex: "DA291C"), scale: .large)
        }
        GridRow {
            LineBadge("C-2", color: Color(hex: "0057A8"))
            LineBadge("C-2", color: Color(hex: "0057A8"), scale: .large)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Colores y textos") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        ForEach(LineBadge.Scale.allCases, id: \.self) { scale in
            HStack(spacing: Spacing.sm) {
                LineBadge("C-1", color: .brandCercanias, scale: scale)
                LineBadge("R", color: .brandPrimary, scale: scale)
                LineBadge("C-10", color: .statusSuccess, scale: scale)
                LineBadge("Aeropuerto", color: .statusInfo, scale: scale)
            }
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.sm) {
        LineBadge("C-1", color: Color(hex: "DA291C"))
        LineBadge("C-2", color: Color(hex: "0057A8"), scale: .large)
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    VStack(spacing: Spacing.md) {
        LineBadge("C-1", color: Color(hex: "DA291C"))
        LineBadge("C-2", color: Color(hex: "0057A8"), scale: .large)
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
