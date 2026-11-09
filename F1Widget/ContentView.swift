import SwiftUI

private enum Section: String, CaseIterable, Identifiable {
    case calendar = "Calendar"
    case results = "Results"
    #if DEBUG
    case gallery = "Widget Gallery"
    #endif

    var id: Self { self }

    var symbol: String {
        switch self {
        case .calendar: "calendar"
        case .results: "flag.checkered"
        #if DEBUG
        case .gallery: "square.grid.2x2"
        #endif
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
                #if DEBUG
                case .gallery: WidgetGalleryView()
                #endif
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
