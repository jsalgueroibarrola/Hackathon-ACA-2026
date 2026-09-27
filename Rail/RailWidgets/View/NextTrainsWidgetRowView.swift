import SwiftUI
import WidgetKit

struct NextTrainsWidgetRowView: View {
    private let row: NextTrainsWidgetRow
    private let timeZone: TimeZone
    private let showsSeparator: Bool

    @Environment(\.widgetFamily) private var family

    init(_ row: NextTrainsWidgetRow, timeZone: TimeZone, showsSeparator: Bool = false) {
        self.row = row
        self.timeZone = timeZone
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            NextTrainsWidgetLineMark(row)
            Text(verbatim: row.destination)
                .font(destinationFont)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(row.date, format: Date.FormatStyle.departureTime(in: timeZone))
                .font(timeFont)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.vertical, verticalPadding)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(.interactiveSeparator)
                    .frame(height: Border.hairline)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var destinationFont: Font {
        switch family {
        case .systemLarge: .body
        case .systemMedium: .subheadline
        default: .caption
        }
    }

    private var timeFont: Font {
        switch family {
        case .systemLarge, .systemMedium: .timeDeparture
        default: .captionEmphasized.monospacedDigit()
        }
    }

    private var verticalPadding: CGFloat {
        switch family {
        case .systemLarge: Spacing.xs + Spacing.xxs
        case .systemMedium: Spacing.xs
        default: Spacing.none
        }
    }
}

struct NextTrainsWidgetLineMark: View {
    private let row: NextTrainsWidgetRow

    @Environment(\.widgetRenderingMode) private var renderingMode

    init(_ row: NextTrainsWidgetRow) {
        self.row = row
    }

    var body: some View {
        if renderingMode == .fullColor {
            LineBadge(row.line, color: Color(hex: row.colorHex))
        } else {
            Text(verbatim: row.line)
                .font(.captionEmphasized)
                .widgetAccentable()
        }
    }
}
