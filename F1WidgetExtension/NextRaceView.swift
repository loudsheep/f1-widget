import F1Core
import SwiftUI
import WidgetKit

struct NextRaceView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NextRaceEntry

    var body: some View {
        if let weekend = entry.weekend, let session = entry.session {
            let content = WidgetContent(weekend: weekend, session: session, now: entry.date)
            switch family {
            case .systemSmall:
                if entry.style == .track, CircuitMap.url(for: weekend.circuit.id) != nil {
                    SmallTrackView(content: content)
                } else {
                    SmallFlagView(content: content)
                }
            default:
                MediumView(content: content)
            }
        } else {
            ContentUnavailableView("No upcoming race", systemImage: "flag.checkered")
        }
    }
}

private struct WidgetContent {
    let weekend: RaceWeekend
    let session: WeekendSession
    let now: Date

    var theme: CountryTheme { CountryTheme.theme(for: weekend.circuit.country) }
    var accent: Color { theme.accent.color }
}

private struct RoundLabel: View {
    let round: Int

    var body: some View {
        Text("R\(round)")
            .font(.caption2.bold().monospacedDigit())
            .foregroundStyle(.white.opacity(0.7))
    }
}

private struct NextIn: View {
    let content: WidgetContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Next in:")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            Text(Countdown.text(until: content.session.start, from: content.now))
                .font(.title3.bold())
                .foregroundStyle(content.accent)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(content.session.kind.title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

private struct CircuitMapView: View {
    let circuitId: String

    var body: some View {
        if let image = CircuitMap.image(for: circuitId) {
            Image(nsImage: image)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.white)
        }
    }
}

private struct SmallFlagView: View {
    let content: WidgetContent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                FlagView(country: content.weekend.circuit.country, width: 48)
                Spacer()
                RoundLabel(round: content.weekend.round)
            }
            Spacer(minLength: 0)
            NextIn(content: content)
            Text(content.weekend.name)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SmallTrackView: View {
    let content: WidgetContent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                CircuitMapView(circuitId: content.weekend.circuit.id)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                RoundLabel(round: content.weekend.round)
            }
            Spacer(minLength: 0)
            Text(content.weekend.name)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(2)
            NextIn(content: content)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MediumView: View {
    let content: WidgetContent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                CircuitMapView(circuitId: content.weekend.circuit.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                NextIn(content: content)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    FlagView(country: content.weekend.circuit.country, width: 22)
                    Text(content.weekend.name)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    RoundLabel(round: content.weekend.round)
                }
                .padding(.bottom, 2)
                ForEach(content.weekend.sessions) { item in
                    let isNext = item.kind == content.session.kind
                    HStack {
                        Text(item.kind.shortTitle)
                        Spacer()
                        Text(item.start, format: .dateTime.weekday(.abbreviated).hour().minute())
                            .monospacedDigit()
                    }
                    .font(.caption2)
                    .fontWeight(isNext ? .bold : .regular)
                    .foregroundStyle(isNext ? content.accent : .white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview(as: .systemSmall) {
    NextRaceWidget()
} timeline: {
    NextRaceProvider.sampleEntry(style: .flag)
    NextRaceProvider.sampleEntry(style: .track)
}

#Preview(as: .systemMedium) {
    NextRaceWidget()
} timeline: {
    NextRaceProvider.sampleEntry(style: .flag)
}
