import Foundation
import Translation

struct AlertTranslation: Equatable {
    struct Translated: Equatable {
        let source: String
        let target: String
    }

    enum State: Equatable {
        case original
        case translating
        case translated(String)
    }

    private(set) var texts: [String: Translated] = [:]
    private(set) var shown: Set<String> = []
    private(set) var configuration: TranslationSession.Configuration?

    func translated(_ item: ServiceAlertItem) -> String? {
        texts[item.id].flatMap { $0.source == item.text ? $0.target : nil }
    }

    func state(for item: ServiceAlertItem) -> State {
        switch (shown.contains(item.id), translated(item)) {
        case (false, _): .original
        case (true, nil): .translating
        case (true, let text?): .translated(text)
        }
    }

    func untranslated(in items: [ServiceAlertItem]) -> [ServiceAlertItem] {
        items.filter { translated($0) == nil }
    }

    func pending(in items: [ServiceAlertItem]) -> Set<String> {
        Set(untranslated(in: items).map(\.id)).intersection(shown)
    }

    static func requests(for items: [ServiceAlertItem]) -> [TranslationSession.Request] {
        items.map {
            TranslationSession.Request(sourceText: $0.text, clientIdentifier: $0.id)
        }
    }

    mutating func toggle(_ id: String) {
        shown.formSymmetricDifference([id])
    }

    mutating func request(_ target: Locale.Language) {
        if configuration == nil {
            configuration = TranslationSession.Configuration(
                source: AlertTranslationSupport.source,
                target: target
            )
        } else {
            configuration?.invalidate()
        }
    }

    mutating func fail(_ items: [ServiceAlertItem]) {
        shown.subtract(items.map(\.id))
        configuration = nil
    }

    mutating func store(
        _ responses: [TranslationSession.Response],
        for items: [ServiceAlertItem]
    ) {
        let sources = Dictionary(
            items.map { ($0.id, $0.text) },
            uniquingKeysWith: { first, _ in first }
        )
        texts.merge(
            responses.compactMap { response in
                response.clientIdentifier.flatMap { id in
                    sources[id].map {
                        (id, Translated(source: $0, target: response.targetText))
                    }
                }
            },
            uniquingKeysWith: { _, new in new }
        )
    }
}

enum AlertTranslationSupport {
    static let source = Locale.Language(identifier: "es")

    static func target(preferredLanguages: [String]) -> Locale.Language? {
        preferredLanguages.first
            .map(Locale.Language.init(identifier:))
            .flatMap { $0.languageCode == source.languageCode ? nil : $0 }
    }

    static func resolve(
        preferredLanguages: [String] = Locale.preferredLanguages
    ) async -> Locale.Language? {
        guard let target = target(preferredLanguages: preferredLanguages) else {
            return nil
        }
        let status = await LanguageAvailability().status(from: source, to: target)
        return status == .unsupported ? nil : target
    }

    static func name(
        of language: Locale.Language,
        in locale: Locale = .autoupdatingCurrent
    ) -> String? {
        language.languageCode.flatMap {
            locale.localizedString(forLanguageCode: $0.identifier)
        }
    }
}
