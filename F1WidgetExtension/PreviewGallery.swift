#if DEBUG
import F1Core
import WidgetKit

private enum PreviewEntries {
    static let schedule = SampleData.season()

    static func entry(
        at date: Date,
        style: WidgetStyle = .flag,
        appearance: WidgetAppearance = .accent
    ) -> NextRaceEntry {
        let next = schedule.nextSession(at: date)
        return NextRaceEntry(
            date: date,
            weekend: next?.weekend,
            session: next?.session,
            style: style,
            appearance: appearance
        )
    }

    static func races(style: WidgetStyle = .flag, appearance: WidgetAppearance = .accent) -> [NextRaceEntry] {
        schedule
            .compactMap(\.firstSessionStart)
            .map { entry(at: $0.addingTimeInterval(-3 * 24 * 3600), style: style, appearance: appearance) }
    }

    static func states(style: WidgetStyle = .flag) -> [NextRaceEntry] {
        guard let first = schedule.first, let last = schedule.last,
              let practice = first.sessions.first, let race = first.sessions.last,
              let finalRace = last.sessions.last
        else { return [] }
        return [
            practice.start.addingTimeInterval(-25 * 60),
            practice.start.addingTimeInterval(20 * 60),
            practice.end.addingTimeInterval(10 * 60),
            race.start.addingTimeInterval(30 * 60),
            finalRace.end.addingTimeInterval(60),
        ].map { entry(at: $0, style: style) }
    }
}

#Preview("Small flag - all races", as: .systemSmall) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.races(style: .flag) {
        entry
    }
}

#Preview("Small track - all races", as: .systemSmall) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.races(style: .track) {
        entry
    }
}

#Preview("Medium - all races", as: .systemMedium) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.races() {
        entry
    }
}

#Preview("Small flag - black and white", as: .systemSmall) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.races(style: .flag, appearance: .monochrome) {
        entry
    }
}

#Preview("Medium - black and white", as: .systemMedium) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.races(appearance: .monochrome) {
        entry
    }
}

#Preview("Small - states", as: .systemSmall) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.states() {
        entry
    }
}

#Preview("Medium - states", as: .systemMedium) {
    NextRaceWidget()
} timeline: {
    for entry in PreviewEntries.states() {
        entry
    }
}
#endif
