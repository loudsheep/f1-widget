import Foundation

public struct F1Repository: Sendable {
    private let client: JolpicaClient
    private let cache: DiskCache

    public init(client: JolpicaClient = JolpicaClient(), cache: DiskCache = .shared) {
        self.client = client
        self.cache = cache
    }

    public func schedule() async throws -> [RaceWeekend] {
        let key = "schedule-current"
        do {
            let schedule = try await client.schedule()
            cache.write(schedule, key: key)
            return schedule
        } catch {
            guard let cached = cache.read([RaceWeekend].self, key: key) else { throw error }
            return cached
        }
    }

    public func results(season: Int, round: Int) async throws -> RaceResults? {
        let key = "results-\(season)-\(round)"
        if let cached = cache.read(RaceResults.self, key: key) {
            return cached
        }
        let results = try await client.results(season: String(season), round: String(round))
        if let results {
            cache.write(results, key: key)
        }
        return results
    }
}
