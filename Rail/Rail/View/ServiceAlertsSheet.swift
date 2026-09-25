import OSLog
import SwiftData
import SwiftUI
@preconcurrency import Translation

struct ServiceAlertsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.liveFeeds) private var liveFeeds
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \ServiceAlert.position) private var alerts: [ServiceAlert]
    @Query private var feeds: [ServiceAlertFeed]
    @Query private var lines: [Line]
    @Query private var networks: [TransitNetwork]
    @State private var lastOutcome: LiveFeedOutcome?
    @State private var retryAttempt = 0
    @State private var target: Locale.Language?
    @State private var translation = AlertTranslation()

    private struct PollTrigger: Equatable {
        let isActive: Bool
        let retryAttempt: Int
    }

    private var pollTrigger: PollTrigger {
        PollTrigger(isActive: scenePhase == .active, retryAttempt: retryAttempt)
    }

    private var calendar: Calendar {
        networks.first?.calendar ?? .autoupdatingCurrent
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            sheet(items: items(at: context.date))
        }
    }

    private func sheet(items: [ServiceAlertItem]) -> some View {
        NavigationStack {
            ServiceAlertsList(
                phase: ServiceAlertsPhase(
                    hasFeed: !feeds.isEmpty,
                    lastOutcome: lastOutcome,
                    items: items
                ),
                translation: translation,
                translationLanguage: target.flatMap {
                    AlertTranslationSupport.name(of: $0)
                },
                onTranslate: { translation.toggle($0) },
                onRetry: {
                    lastOutcome = nil
                    retryAttempt += 1
                }
            )
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .task(id: pollTrigger) {
            guard pollTrigger.isActive else { return }
            await liveFeeds.poll(.alerts) { lastOutcome = $0.outcome }
        }
        .task {
            target = await AlertTranslationSupport.resolve()
        }
        .onChange(of: translation.pending(in: items)) { _, pending in
            guard !pending.isEmpty, let target else { return }
            translation.request(target)
        }
        .translationTask(translation.configuration) { session in
            await translate(translation.untranslated(in: items), using: session)
        }
    }

    private func items(at date: Date) -> [ServiceAlertItem] {
        ServiceAlertItemBuilder.items(
            alerts: alerts,
            lines: lines,
            now: date,
            calendar: calendar,
            locale: .autoupdatingCurrent,
            dateLocale: AlertTimestamp.dateLocale(
                preferredLanguages: Locale.preferredLanguages
            )
        )
    }

    private func translate(
        _ untranslated: [ServiceAlertItem],
        using session: TranslationSession
    ) async {
        guard !untranslated.isEmpty else { return }
        do {
            let responses = try await session.translations(
                from: AlertTranslation.requests(for: untranslated)
            )
            translation.store(responses, for: untranslated)
        } catch {
            guard !Task.isCancelled else { return }
            Logger.liveFeeds.error(
                "Alert translation failed: \(error.localizedDescription)"
            )
            translation.fail(untranslated)
        }
    }

    static let title = LocalizedStringResource(
        "Notificaciones",
        comment:
            "Título de la hoja de avisos de Renfe que se abre desde la campana de Inicio, y etiqueta de esa campana para VoiceOver."
    )
}

#if DEBUG
    #Preview("Con avisos", traits: .serviceAlertsSampleData) {
        ServiceAlertsSheet()
    }

    #Preview("Sin avisos", traits: .noServiceAlertsSampleData) {
        ServiceAlertsSheet()
    }

    #Preview("Sin conexión", traits: .nextTrainsSampleData) {
        ServiceAlertsSheet()
    }

    #Preview("Modo oscuro", traits: .serviceAlertsSampleData) {
        ServiceAlertsSheet()
            .preferredColorScheme(.dark)
    }
#endif
