#if DEBUG
import F1Core
import SwiftUI
import WidgetKit

private enum TileSize {
    static let small = CGSize(width: 158, height: 158)
    static let medium = CGSize(width: 338, height: 158)
}

private struct GalleryTile: View {
    let entry: NextRaceEntry
    let family: WidgetFamily

    private var size: CGSize {
        family == .systemSmall ? TileSize.small : TileSize.medium
    }

    var body: some View {
        NextRaceContent(entry: entry, family: family)
            .environment(\.colorScheme, .dark)
            .padding(16)
            .frame(width: size.width, height: size.height)
            .background { WidgetBackground(theme: entry.theme, appearance: entry.appearance) }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private func entry(
    at date: Date,
    schedule: [RaceWeekend],
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

private struct RaceGallery: View {
    let appearance: WidgetAppearance
    private let schedule = SampleData.season()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(schedule) { weekend in
                    let date = (weekend.firstSessionStart ?? .now).addingTimeInterval(-3 * 24 * 3600)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("R\(weekend.round) \(weekend.name)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            GalleryTile(entry: entry(at: date, schedule: schedule, style: .flag, appearance: appearance), family: .systemSmall)
                            GalleryTile(entry: entry(at: date, schedule: schedule, style: .track, appearance: appearance), family: .systemSmall)
                            GalleryTile(entry: entry(at: date, schedule: schedule, appearance: appearance), family: .systemMedium)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(white: 0.15))
    }
}

private struct StateGallery: View {
    private let schedule = SampleData.season()

    private var states: [(String, Date)] {
        guard let first = schedule.first, let last = schedule.last,
              let practice = first.sessions.first, let race = first.sessions.last,
              let finalRace = last.sessions.last
        else { return [] }
        return [
            ("Practice live", practice.start.addingTimeInterval(20 * 60)),
            ("Race live", race.start.addingTimeInterval(30 * 60)),
            ("Between sessions", practice.end.addingTimeInterval(10 * 60)),
            ("Under an hour to start", practice.start.addingTimeInterval(-25 * 60)),
            ("Season over", finalRace.end.addingTimeInterval(60)),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(states, id: \.0) { label, date in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(label)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            GalleryTile(entry: entry(at: date, schedule: schedule), family: .systemSmall)
                            GalleryTile(entry: entry(at: date, schedule: schedule, style: .track), family: .systemSmall)
                            GalleryTile(entry: entry(at: date, schedule: schedule), family: .systemMedium)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(white: 0.15))
    }
}

#Preview("All races - accent", traits: .fixedLayout(width: 760, height: 900)) {
    RaceGallery(appearance: .accent)
}

#Preview("All races - black and white", traits: .fixedLayout(width: 760, height: 900)) {
    RaceGallery(appearance: .monochrome)
}

#Preview("States", traits: .fixedLayout(width: 760, height: 900)) {
    StateGallery()
}
#endif
