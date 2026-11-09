import F1Core
import SwiftUI

struct CalendarView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List(model.schedule) { weekend in
            WeekendRow(weekend: weekend, isNext: weekend.id == model.upcomingWeekend?.id)
        }
        .navigationTitle("Season Calendar")
        .overlay {
            if model.schedule.isEmpty {
                ContentUnavailableView("No schedule", systemImage: "calendar.badge.exclamationmark")
            }
        }
    }
}

private struct WeekendRow: View {
    let weekend: RaceWeekend
    let isNext: Bool

    var body: some View {
        HStack(spacing: 12) {
            FlagView(country: weekend.circuit.country, width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("Round \(weekend.round)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(weekend.name)
                    .font(.headline)
                Text("\(weekend.circuit.name), \(weekend.circuit.locality)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let start = weekend.raceStart {
                Text(start, format: .dateTime.day().month(.abbreviated).hour().minute())
                    .monospacedDigit()
            }
            if isNext {
                Text("Next")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.tint, in: .capsule)
                    .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 4)
    }
}
