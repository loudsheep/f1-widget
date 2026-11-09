import SwiftUI

public struct NextRaceWidgetView: View {
    private let weekend: RaceWeekend?
    private let session: WeekendSession?
    private let now: Date
    private let style: WidgetStyle
    private let appearance: WidgetAppearance
    private let layout: WidgetLayout

    public init(
        weekend: RaceWeekend?,
        session: WeekendSession?,
        now: Date,
        style: WidgetStyle,
        appearance: WidgetAppearance,
        layout: WidgetLayout
    ) {
        self.weekend = weekend
        self.session = session
        self.now = now
        self.style = style
        self.appearance = appearance
        self.layout = layout
    }

    public var body: some View {
        Group {
            if let weekend, let session {
                let content = WidgetContent(weekend: weekend, session: session, now: now, appearance: appearance)
                switch layout {
                case .small:
                    if style == .track, CircuitMap.url(for: weekend.circuit.id) != nil {
                        SmallTrackView(content: content)
                    } else {
                        SmallFlagView(content: content)
                    }
                case .medium:
                    MediumView(content: content)
                }
            } else {
                ContentUnavailableView("No upcoming race", systemImage: "flag.checkered")
            }
        }
        .fontDesign(.monospaced)
        .environment(\.colorScheme, .dark)
    }
}

public struct WidgetBackground: View {
    private let weekend: RaceWeekend?
    private let appearance: WidgetAppearance

    public init(weekend: RaceWeekend?, appearance: WidgetAppearance) {
        self.weekend = weekend
        self.appearance = appearance
    }

    private var theme: CountryTheme {
        weekend.map { CountryTheme.theme(for: $0.circuit.country) } ?? .fallback
    }

    public var body: some View {
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

struct WidgetContent {
    let weekend: RaceWeekend
    let session: WeekendSession
    let now: Date
    let appearance: WidgetAppearance

    var accent: Color {
        switch appearance {
        case .accent: CountryTheme.theme(for: weekend.circuit.country).accent.color
        case .monochrome: .white
        }
    }
}

struct RoundLabel: View {
    let round: Int

    var body: some View {
        Text("R\(round)")
            .font(.caption2.bold().monospacedDigit())
            .foregroundStyle(.white.opacity(0.7))
    }
}

struct NextIn: View {
    let content: WidgetContent

    private var isLive: Bool {
        content.session.isLive(at: content.now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isLive ? "Now:" : "Next in:")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            Text(isLive ? "Live" : Countdown.text(until: content.session.start, from: content.now))
                .font(.title3.weight(.heavy))
                .foregroundStyle(content.accent)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(content.session.kind.title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

struct CircuitMapView: View {
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

struct SmallFlagView: View {
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

struct SmallTrackView: View {
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

struct CompactCountdown: View {
    let content: WidgetContent

    var body: some View {
        let isLive = content.session.isLive(at: content.now)
        Text(isLive ? "Live" : Countdown.text(until: content.session.start, from: content.now))
            .font(.caption.bold())
            .foregroundStyle(content.accent)
            .minimumScaleFactor(0.7)
            .lineLimit(1)
    }
}

struct MediumView: View {
    let content: WidgetContent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            leading
                .frame(maxWidth: .infinity, alignment: .leading)
            sessionCards
                .frame(maxWidth: .infinity)
        }
    }

    private var leading: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(CountryFlag.grandPrixCode(for: content.weekend.circuit.country)) GP")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    Text(content.weekend.circuit.locality)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                FlagView(country: content.weekend.circuit.country, width: 36)
            }
            CircuitMapView(circuitId: content.weekend.circuit.id)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 2)
            HStack {
                Text("R\(content.weekend.round)")
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
                CompactCountdown(content: content)
            }
        }
    }

    private var sessionCards: some View {
        VStack(spacing: 4) {
            ForEach(content.weekend.sessionsByDay()) { day in
                DayCard(day: day, content: content)
            }
        }
    }
}

struct DayCard: View {
    let day: SessionDay
    let content: WidgetContent

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(day.sessions) { session in
                row(for: session)
            }
            Text(day.day, format: .dateTime.month(.abbreviated).day().weekday(.abbreviated))
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 8)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func row(for session: WeekendSession) -> some View {
        let isCurrent = session.kind == content.session.kind
        let isOver = session.end <= content.now
        return HStack(spacing: 4) {
            Capsule()
                .fill(content.accent)
                .frame(width: 3, height: 11)
            Text(session.kind.title)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 2)
            Text(session.start, format: .dateTime.hour().minute())
                .font(.caption2.monospacedDigit())
                .foregroundStyle(isCurrent ? content.accent : .white.opacity(0.7))
        }
        .foregroundStyle(.white)
        .opacity(isOver ? 0.4 : 1)
    }
}
