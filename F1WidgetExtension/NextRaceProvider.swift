import F1Core
import WidgetKit

struct NextRaceEntry: TimelineEntry {
    let date: Date
    let weekend: RaceWeekend?
    let session: WeekendSession?
    let style: WidgetStyle
    let appearance: WidgetAppearance
}

struct NextRaceProvider: AppIntentTimelineProvider {
    private static let step: TimeInterval = 10 * 60
    private static let horizon: TimeInterval = 24 * 60 * 60

    private let repository = F1Repository()

    func placeholder(in context: Context) -> NextRaceEntry {
        Self.sampleEntry(style: .flag, appearance: .accent)
    }

    func snapshot(for configuration: NextRaceIntent, in context: Context) async -> NextRaceEntry {
        guard !context.isPreview, let schedule = try? await repository.schedule() else {
            return Self.sampleEntry(style: configuration.style, appearance: configuration.appearance)
        }
        return Self.entry(at: .now, schedule: schedule, configuration: configuration)
    }

    func timeline(for configuration: NextRaceIntent, in context: Context) async -> Timeline<NextRaceEntry> {
        let now = Date.now
        guard let schedule = try? await repository.schedule() else {
            return Timeline(
                entries: [
                    NextRaceEntry(
                        date: now,
                        weekend: nil,
                        session: nil,
                        style: configuration.style,
                        appearance: configuration.appearance
                    ),
                ],
                policy: .after(now.addingTimeInterval(30 * 60))
            )
        }

        let end = now.addingTimeInterval(Self.horizon)
        var dates = Array(stride(from: now, to: end, by: Self.step))
        if let session = schedule.nextSession(at: now)?.session {
            dates += [session.start, session.end].filter { $0 > now && $0 < end }
        }
        dates = Array(Set(dates)).sorted()

        let entries = dates.map { Self.entry(at: $0, schedule: schedule, configuration: configuration) }
        return Timeline(entries: entries, policy: .after(dates.last ?? end))
    }

    static func entry(at date: Date, schedule: [RaceWeekend], configuration: NextRaceIntent) -> NextRaceEntry {
        let next = schedule.nextSession(at: date)
        return NextRaceEntry(
            date: date,
            weekend: next?.weekend,
            session: next?.session,
            style: configuration.style,
            appearance: configuration.appearance
        )
    }

    static func sampleEntry(style: WidgetStyle, appearance: WidgetAppearance = .accent) -> NextRaceEntry {
        let start = Date.now.addingTimeInterval(3 * 3600 + 25 * 60)
        let weekend = RaceWeekend(
            season: 2026,
            round: 1,
            name: "Australian Grand Prix",
            circuit: Circuit(id: "albert_park", name: "Albert Park", locality: "Melbourne", country: "Australia"),
            sessions: [
                WeekendSession(kind: .firstPractice, start: start),
                WeekendSession(kind: .secondPractice, start: start.addingTimeInterval(3.5 * 3600)),
                WeekendSession(kind: .thirdPractice, start: start.addingTimeInterval(24 * 3600)),
                WeekendSession(kind: .qualifying, start: start.addingTimeInterval(27 * 3600)),
                WeekendSession(kind: .race, start: start.addingTimeInterval(48 * 3600)),
            ]
        )
        return NextRaceEntry(date: .now, weekend: weekend, session: weekend.sessions.first, style: style, appearance: appearance)
    }
}
