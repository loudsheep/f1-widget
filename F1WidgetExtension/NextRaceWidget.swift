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
                    WidgetBackground(theme: entry.theme, appearance: entry.appearance)
                }
        }
        .configurationDisplayName("Next Race")
        .description("The next Formula 1 session and a countdown to it.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetBackground: View {
    let theme: CountryTheme
    let appearance: WidgetAppearance

    var body: some View {
        ZStack {
            Color.black
            if appearance == .accent {
                glow
            }
        }
    }

    private var glow: some View {
        ZStack {
            RadialGradient(
                colors: [theme.glowPrimary.color.opacity(0.75), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 260
            )
            RadialGradient(
                colors: [theme.glowSecondary.color.opacity(0.55), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 260
            )
        }
    }
}

extension NextRaceEntry {
    var theme: CountryTheme {
        weekend.map { CountryTheme.theme(for: $0.circuit.country) } ?? .fallback
    }
}
