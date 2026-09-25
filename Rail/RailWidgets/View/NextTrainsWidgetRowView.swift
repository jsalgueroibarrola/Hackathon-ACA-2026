import SwiftUI
import WidgetKit

struct NextTrainsWidgetRowView: View {
    private let row: NextTrainsWidgetRow
    private let timeZone: TimeZone

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    init(_ row: NextTrainsWidgetRow, timeZone: TimeZone) {
        self.row = row
        self.timeZone = timeZone
    }

    var body: some View {
        content
            .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        if family == .systemSmall {
            VStack(alignment: .leading, spacing: Spacing.none) {
                HStack(spacing: Spacing.sm) {
                    line
                    time
                }
                destination
            }
        } else {
            HStack(spacing: Spacing.sm) {
                line
                destination
                    .frame(maxWidth: .infinity, alignment: .leading)
                time
            }
        }
    }

    @ViewBuilder
    private var line: some View {
        if renderingMode == .fullColor {
            LineBadge(row.line, color: Color(hex: row.colorHex))
        } else {
            Text(verbatim: row.line)
                .font(.captionEmphasized)
                .widgetAccentable()
        }
    }

    private var destination: some View {
        Text(verbatim: row.destination)
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
    }

    private var time: some View {
        Text(row.date, format: Date.FormatStyle.departureTime(in: timeZone))
            .font(.timeDeparture)
            .lineLimit(1)
            .fixedSize()
    }
}
