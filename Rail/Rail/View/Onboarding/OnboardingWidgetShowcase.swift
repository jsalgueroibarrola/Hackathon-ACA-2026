import SwiftData
import SwiftUI

struct OnboardingWidgetShowcase: View {
    @Query private var lines: [Line]
    @Query private var networks: [TransitNetwork]

    private static let widgetSize = CGSize(width: 338, height: 158)
    private static let smallWidgetSide: CGFloat = 158
    private static let appIconSide: CGFloat = 64
    private static let homeScreenSpacing: CGFloat = 22
    fileprivate static let widgetRadius: CGFloat = 22
    private static let trainHeight: CGFloat = 48
    private static let trainBleed: CGFloat = 28
    private static let headerTrailingInset: CGFloat = 96

    private var sample: OnboardingWidgetSample? {
        OnboardingWidgetSampleBuilder.sample(lines: lines)
    }

    private var timeZone: TimeZone {
        networks.first?.timeZone ?? .current
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let sample = sample ?? .placeholder
            ViewThatFits(in: .vertical) {
                VStack(alignment: .leading, spacing: Self.homeScreenSpacing) {
                    HStack(alignment: .top, spacing: Self.homeScreenSpacing) {
                        labeled { smallWidget(sample, now: context.date) }
                        labeled {
                            RailLogo()
                                .frame(width: Self.appIconSide, height: Self.appIconSide)
                                .elevation(.card)
                        }
                    }
                    labeled { widget(sample, now: context.date) }
                }
                labeled { widget(sample, now: context.date) }
            }
            .frame(maxWidth: Self.widgetSize.width)
            .redacted(reason: self.sample == nil ? .placeholder : [])
        }
        .dynamicTypeSize(.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.top, OnboardingLayout.regularTopInset)
        .padding(.bottom, Spacing.lg)
    }

    private func widget(_ sample: OnboardingWidgetSample, now: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(verbatim: sample.station)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                Label(Self.nextTrains, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.trailing, Self.headerTrailingInset)
            Spacer(minLength: Spacing.none)
            VStack(spacing: Spacing.none) {
                ForEach(sample.rows) { row in
                    departure(row, now: now, showsSeparator: row.id != sample.rows.last?.id)
                }
            }
        }
        .padding(Spacing.lg)
        .frame(
            maxWidth: Self.widgetSize.width,
            minHeight: Self.widgetSize.height,
            maxHeight: Self.widgetSize.height,
            alignment: .topLeading
        )
        .overlay(alignment: .topTrailing) {
            TrainIllustration()
                .frame(height: Self.trainHeight)
                .padding(.top, Spacing.md)
                .offset(x: Self.trainBleed)
        }
        .widgetSurface()
    }

    private func labeled<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: Spacing.xs) {
            content()
            Text(verbatim: "Rail")
                .font(.caption2)
                .foregroundStyle(.textSecondary)
        }
    }

    private func smallWidget(_ sample: OnboardingWidgetSample, now: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(verbatim: sample.station)
                .font(.captionEmphasized)
                .foregroundStyle(.textSecondary)
                .lineLimit(2)
            Spacer(minLength: Spacing.xs)
            if let first = sample.rows.first {
                ViewThatFits(in: .horizontal) {
                    heroDestination(first, showsArrow: true)
                    heroDestination(first, showsArrow: false)
                }
                .foregroundStyle(.textPrimary)
                Text(departureDate(first, now: now), format: Date.FormatStyle.departureTime(in: timeZone))
                    .font(.timeDepartureHero)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(Self.minutesAway(first.minutesAway))
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .frame(
            width: Self.smallWidgetSide,
            height: Self.smallWidgetSide,
            alignment: .topLeading
        )
        .widgetSurface()
    }

    private func heroDestination(_ row: OnboardingWidgetSample.Row, showsArrow: Bool) -> some View {
        HStack(spacing: Spacing.xs) {
            LineBadge(row.id, color: row.color)
            if showsArrow {
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
            }
            Text(verbatim: row.destination)
                .font(.subheadlineEmphasized)
                .lineLimit(1)
                .minimumScaleFactor(showsArrow ? 1 : 0.85)
        }
    }

    private func departureDate(_ row: OnboardingWidgetSample.Row, now: Date) -> Date {
        now.addingTimeInterval(TimeInterval(row.minutesAway * 60))
    }

    private func departure(
        _ row: OnboardingWidgetSample.Row,
        now: Date,
        showsSeparator: Bool
    ) -> some View {
        HStack(spacing: Spacing.sm) {
            LineBadge(row.id, color: row.color)
            Text(verbatim: row.destination)
                .font(.subheadline)
                .foregroundStyle(.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(departureDate(row, now: now), format: Date.FormatStyle.departureTime(in: timeZone))
            .font(.timeDeparture)
            .foregroundStyle(.textPrimary)
        }
        .padding(.vertical, Spacing.xs)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(.interactiveSeparator)
                    .frame(height: Border.hairline)
            }
        }
    }

    private static func minutesAway(_ minutes: Int) -> LocalizedStringResource {
        LocalizedStringResource(
            "En \(minutes) min",
            comment: "Bienvenida, paso del widget: cuenta atrás hasta la próxima salida en el widget pequeño de muestra, por ejemplo «En 4 min»."
        )
    }

    private static let nextTrains = LocalizedStringResource(
        "Próximos trenes",
        comment: "Bienvenida, paso del widget: cabecera del widget de muestra con las próximas salidas."
    )
}

private extension View {
    func widgetSurface() -> some View {
        background(.bgPrimary)
            .clipShape(.rect(cornerRadius: OnboardingWidgetShowcase.widgetRadius, style: .continuous))
            .elevation(.floating)
    }
}

#if DEBUG
#Preview("Variantes Figma", traits: .nextTrainsSampleData) {
    OnboardingWidgetShowcase()
        .frame(height: 360)
        .background(.bgSecondary)
}

#Preview("Descargando") {
    OnboardingWidgetShowcase()
        .frame(height: 360)
        .background(.bgSecondary)
        .modelContainer(for: RailSchema.models, inMemory: true)
}

#Preview("Modo oscuro", traits: .nextTrainsSampleData) {
    OnboardingWidgetShowcase()
        .frame(height: 360)
        .background(.bgSecondary)
        .preferredColorScheme(.dark)
}
#endif
