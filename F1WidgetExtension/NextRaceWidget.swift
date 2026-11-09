import F1Core
import SwiftUI
import WidgetKit

struct NextRaceWidget: Widget {
    let kind = "NextRaceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: NextRaceIntent.self, provider: NextRaceProvider()) { entry in
            NextRaceView(entry: entry)
                .environment(\.colorScheme, .dark)
                .containerBackground(for: .widget) {
                    WidgetBackground(theme: entry.theme)
                }
        }
        .configurationDisplayName("Next Race")
        .description("The next Formula 1 session and a countdown to it.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetBackground: View {
    let theme: CountryTheme

    var body: some View {
        ZStack {
            Color.black
            RadialGradient(
                colors: [theme.glowPrimary.color.opacity(0.55), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 240
            )
            RadialGradient(
                colors: [theme.glowSecondary.color.opacity(0.4), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 240
            )
        }
    }
}

extension NextRaceEntry {
    var theme: CountryTheme {
        weekend.map { CountryTheme.theme(for: $0.circuit.country) } ?? .fallback
    }
}
