import WidgetKit

struct NextTrainsWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> NextTrainsWidgetEntry {
        .sample(at: .now, limit: context.family.maxDepartures)
    }

    func snapshot(
        for configuration: SelectFavoriteStationIntent,
        in context: Context
    ) async -> NextTrainsWidgetEntry {
        context.isPreview
            ? .sample(at: .now, limit: context.family.maxDepartures)
            : currentTimeline(for: configuration, in: context).entries.first
                ?? .sample(at: .now, limit: context.family.maxDepartures)
    }

    func timeline(
        for configuration: SelectFavoriteStationIntent,
        in context: Context
    ) async -> Timeline<NextTrainsWidgetEntry> {
        currentTimeline(for: configuration, in: context)
    }

    private func currentTimeline(
        for configuration: SelectFavoriteStationIntent,
        in context: Context,
        now: Date = .now
    ) -> Timeline<NextTrainsWidgetEntry> {
        guard let stationID = configuration.station?.id else {
            return NextTrainsTimelineBuilder.unconfigured(now: now)
        }

        return NextTrainsTimelineBuilder.timeline(
            for: RailWidgetStore.snapshot(stationID: stationID, now: now),
            now: now,
            limit: context.family.maxDepartures
        )
    }
}
