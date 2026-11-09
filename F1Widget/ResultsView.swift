import F1Core
import SwiftUI

struct ResultsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            Picker("Race", selection: $model.selectedResultsRound) {
                ForEach(model.completedWeekends) { weekend in
                    Text("R\(weekend.round) \(weekend.name)").tag(Optional(weekend.round))
                }
            }
            .padding()

            if let results = model.results {
                Table(results.entries) {
                    TableColumn("Pos") { Text($0.positionText) }.width(40)
                    TableColumn("Driver", value: \.driverName)
                    TableColumn("Team", value: \.constructor)
                    TableColumn("Grid") { Text($0.grid, format: .number) }.width(50)
                    TableColumn("Time / Status") { Text($0.time ?? $0.status) }
                    TableColumn("Pts") { Text($0.points, format: .number) }.width(50)
                }
            } else {
                ContentUnavailableView("No results", systemImage: "flag.checkered")
            }
        }
        .navigationTitle("Results")
        .onChange(of: model.selectedResultsRound) {
            Task { await model.loadSelectedResults() }
        }
    }
}
