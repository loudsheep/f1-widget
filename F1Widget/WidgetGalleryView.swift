#if DEBUG
import F1Core
import SwiftUI

struct WidgetGalleryView: View {
    @State private var appearance: WidgetAppearance = .accent
    private let schedule = SampleData.season()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Picker("Appearance", selection: $appearance) {
                    Text("Accent colors").tag(WidgetAppearance.accent)
                    Text("Black and white").tag(WidgetAppearance.monochrome)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)

                section("States", rows: states)
                section("All races", rows: races)
            }
            .padding(20)
        }
        .navigationTitle("Widget Gallery")
    }

    private var races: [(String, Date)] {
        schedule.compactMap { weekend in
            weekend.firstSessionStart.map {
                ("R\(weekend.round) \(weekend.name)", $0.addingTimeInterval(-3 * 24 * 3600))
            }
        }
    }

    private var states: [(String, Date)] {
        guard let first = schedule.first, let last = schedule.last,
              let practice = first.sessions.first, let race = first.sessions.last,
              let finalRace = last.sessions.last
        else { return [] }
        return [
            ("Under an hour to start", practice.start.addingTimeInterval(-25 * 60)),
            ("Practice live", practice.start.addingTimeInterval(20 * 60)),
            ("Between sessions", practice.end.addingTimeInterval(10 * 60)),
            ("Race live", race.start.addingTimeInterval(30 * 60)),
            ("Season over", finalRace.end.addingTimeInterval(60)),
        ]
    }

    private func section(_ title: String, rows: [(String, Date)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title2.bold())
            ForEach(rows, id: \.0) { label, date in
                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        tile(at: date, style: .flag, layout: .small)
                        tile(at: date, style: .track, layout: .small)
                        tile(at: date, style: .flag, layout: .medium)
                    }
                }
            }
        }
    }

    private func tile(at date: Date, style: WidgetStyle, layout: WidgetLayout) -> some View {
        let next = schedule.nextSession(at: date)
        return NextRaceWidgetView(
            weekend: next?.weekend,
            session: next?.session,
            now: date,
            style: style,
            appearance: appearance,
            layout: layout
        )
        .padding(16)
        .frame(width: layout.size.width, height: layout.size.height)
        .background { WidgetBackground(weekend: next?.weekend, appearance: appearance) }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
#endif
