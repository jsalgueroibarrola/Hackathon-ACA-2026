import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case privacy
    case location
    case alerts
    case widgets
    case stations
}

extension OnboardingStep {
    static var count: Int { allCases.count }

    var number: Int { rawValue + 1 }

    var previous: Self? { Self(rawValue: rawValue - 1) }

    var next: Self? { Self(rawValue: rawValue + 1) }

    var hasArtwork: Bool { self != .stations }

    var accessibilityLabel: LocalizedStringResource {
        LocalizedStringResource(
            "Paso \(number) de \(Self.count)",
            comment: "Bienvenida: VoiceOver lee el progreso, por ejemplo «Paso 2 de 4»."
        )
    }
}
