import F1Core
import SwiftUI
import WidgetKit

struct NextRaceView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NextRaceEntry

    var body: some View {
        if let weekend = entry.weekend, let session = entry.session {
            switch family {
            case .systemSmall:
                if entry.style == .track, CircuitMap.url(for: weekend.circuit.id) != nil {
                    SmallTrackView(weekend: weekend, session: session, now: entry.date)
                } else {
                    SmallFlagView(weekend: weekend, session: session, now: entry.date)
                }
            default:
                MediumView(weekend: weekend, session: session, now: entry.date)
            }
        } else {
            ContentUnavailableView("No upcoming race", systemImage: "flag.checkered")
        }
    }
}

private struct NextIn: View {
    let session: WeekendSession
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Next in:")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(Countdown.text(until: session.start, from: now))
                .font(.title3.bold())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(session.kind.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
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
                .foregroundStyle(.primary)
        }
    }
}

private struct SmallFlagView: View {
    let weekend: RaceWeekend
    let session: WeekendSession
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(CountryFlag.emoji(for: weekend.circuit.country))
                .font(.system(size: 40))
            Spacer(minLength: 0)
            NextIn(session: session, now: now)
            Text(weekend.name)
                .font(.caption.bold())
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SmallTrackView: View {
    let weekend: RaceWeekend
    let session: WeekendSession
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CircuitMapView(circuitId: weekend.circuit.id)
                .frame(maxWidth: .infinity, maxHeight: 60)
            Spacer(minLength: 0)
            Text(weekend.name)
                .font(.caption.bold())
                .lineLimit(2)
            NextIn(session: session, now: now)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MediumView: View {
    let weekend: RaceWeekend
    let session: WeekendSession
    let now: Date

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                CircuitMapView(circuitId: weekend.circuit.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                NextIn(session: session, now: now)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(CountryFlag.emoji(for: weekend.circuit.country))
                    Text(weekend.name)
                        .font(.caption.bold())
                        .lineLimit(1)
                }
                ForEach(weekend.sessions) { item in
                    HStack {
                        Text(item.kind.shortTitle)
                        Spacer()
                        Text(item.start, format: .dateTime.weekday(.abbreviated).hour().minute())
                            .monospacedDigit()
                    }
                    .font(.caption2)
                    .foregroundStyle(item.kind == session.kind ? .primary : .secondary)
                    .fontWeight(item.kind == session.kind ? .bold : .regular)
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
