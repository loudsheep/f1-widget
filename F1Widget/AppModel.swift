import F1Core
import Observation
import WidgetKit

@MainActor
@Observable
final class AppModel {
    private(set) var schedule: [RaceWeekend] = []
    private(set) var results: RaceResults?
    private(set) var errorMessage: String?
    var selectedResultsRound: Int?

    private let repository = F1Repository()

    func refresh() async {
        do {
            schedule = try await repository.schedule()
            errorMessage = nil
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
        if selectedResultsRound == nil {
            selectedResultsRound = completedWeekends.last?.round
        }
        await loadSelectedResults()
    }

    func loadSelectedResults() async {
        guard let round = selectedResultsRound, let season = schedule.first?.season else {
            results = nil
            return
        }
        do {
            results = try await repository.results(season: season, round: round)
        } catch {
            results = nil
            errorMessage = error.localizedDescription
        }
    }

    var completedWeekends: [RaceWeekend] {
        schedule.filter { ($0.finish ?? .distantFuture) < .now }
    }

    var upcomingWeekend: RaceWeekend? {
        schedule.upcomingWeekend(at: .now)
    }
}
