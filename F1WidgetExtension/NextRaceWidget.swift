import SwiftUI
import WidgetKit

struct NextRaceWidget: Widget {
    let kind = "NextRaceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: NextRaceIntent.self, provider: NextRaceProvider()) { entry in
            NextRaceView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Race")
        .description("The next Formula 1 session and a countdown to it.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
