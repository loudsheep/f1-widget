import AppIntents
import WidgetKit

enum WidgetStyle: String, AppEnum {
    case flag
    case track

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Style"
    static let caseDisplayRepresentations: [WidgetStyle: DisplayRepresentation] = [
        .flag: "Flag",
        .track: "Track",
    ]
}

struct NextRaceIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Next Race"
    static let description = IntentDescription("Shows the next Formula 1 session.")

    @Parameter(title: "Small widget style", default: .flag)
    var style: WidgetStyle
}
