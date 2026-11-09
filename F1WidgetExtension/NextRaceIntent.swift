import AppIntents
import F1Core
import WidgetKit

enum StyleOption: String, AppEnum {
    case flag
    case track

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Style"
    static let caseDisplayRepresentations: [StyleOption: DisplayRepresentation] = [
        .flag: "Flag",
        .track: "Track",
    ]

    var style: WidgetStyle {
        switch self {
        case .flag: .flag
        case .track: .track
        }
    }
}

enum AppearanceOption: String, AppEnum {
    case accent
    case monochrome

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Appearance"
    static let caseDisplayRepresentations: [AppearanceOption: DisplayRepresentation] = [
        .accent: "Accent colors",
        .monochrome: "Black and white",
    ]

    var appearance: WidgetAppearance {
        switch self {
        case .accent: .accent
        case .monochrome: .monochrome
        }
    }
}

struct NextRaceIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Next Race"
    static let description = IntentDescription("Shows the next Formula 1 session.")

    @Parameter(title: "Small widget style", default: .flag)
    var style: StyleOption

    @Parameter(title: "Appearance", default: .accent)
    var appearance: AppearanceOption
}
