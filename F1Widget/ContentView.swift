import SwiftUI

private enum Section: String, CaseIterable, Identifiable {
    case calendar = "Calendar"
    case results = "Results"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .calendar: "calendar"
        case .results: "flag.checkered"
        }
    }
}

struct ContentView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: Section? = .calendar

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selection) { section in
                Label(section.rawValue, systemImage: section.symbol)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180)
        } detail: {
            VStack(spacing: 0) {
                if let message = model.errorMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(8)
                }
                switch selection ?? .calendar {
                case .calendar: CalendarView()
                case .results: ResultsView()
                }
            }
        }
        .toolbar {
            Button("Refresh", systemImage: "arrow.clockwise") {
                Task { await model.refresh() }
            }
        }
    }
}
