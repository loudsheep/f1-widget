import Foundation
import Testing
@testable import F1Core

private func fixture(_ name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
    return try Data(contentsOf: url)
}

private func loadSchedule() throws -> [RaceWeekend] {
    try JolpicaClient.decodeSchedule(fixture("season"))
}

@Suite struct ScheduleDecodingTests {
    @Test func decodesEveryRace() throws {
        let schedule = try loadSchedule()
        #expect(schedule.count == 23)
        #expect(schedule.map(\.round) == Array(1...23))
    }

    @Test func standardWeekendHasFiveSessions() throws {
        let australia = try #require(try loadSchedule().first { $0.circuit.id == "albert_park" })
        #expect(australia.sessions.map(\.kind) == [.firstPractice, .secondPractice, .thirdPractice, .qualifying, .race])
    }

    @Test func sprintWeekendHasSprintSessions() throws {
        let china = try #require(try loadSchedule().first { $0.circuit.id == "shanghai" })
        #expect(china.sessions.map(\.kind) == [.firstPractice, .sprintQualifying, .sprint, .qualifying, .race])
    }

    @Test func sessionsAreChronological() throws {
        for weekend in try loadSchedule() {
            #expect(weekend.sessions.map(\.start) == weekend.sessions.map(\.start).sorted())
        }
    }

    @Test func decodesLastRaceResults() throws {
        let results = try #require(try JolpicaClient.decodeResults(fixture("results")))
        #expect(results.entries.first?.position == 1)
        #expect(results.entries.first?.driverCode == "NOR")
        #expect(!results.entries.isEmpty)
    }
}

@Suite struct NextSessionTests {
    @Test func picksFirstSessionAfterDate() throws {
        let schedule = try loadSchedule()
        let beforeSeason = Date(timeIntervalSince1970: 0)
        let next = try #require(schedule.nextSession(at: beforeSeason))
        #expect(next.weekend.round == 1)
        #expect(next.session.kind == .firstPractice)
    }

    @Test func advancesAtSessionBoundary() throws {
        let schedule = try loadSchedule()
        let first = try #require(schedule.first)
        let secondSession = first.sessions[1]
        let next = try #require(schedule.nextSession(at: first.sessions[0].start))
        #expect(next.session == secondSession)
    }

    @Test func returnsNilAfterSeasonEnds() throws {
        #expect(try loadSchedule().nextSession(at: .distantFuture) == nil)
        #expect(try loadSchedule().upcomingWeekend(at: .distantFuture) == nil)
    }
}

@Suite struct CountdownTests {
    private let now = Date(timeIntervalSince1970: 1_000_000)

    @Test func formatsDaysHoursMinutes() {
        #expect(Countdown.text(until: now.addingTimeInterval(2 * 86400 + 5 * 3600), from: now) == "2 d, 5 h")
        #expect(Countdown.text(until: now.addingTimeInterval(3 * 3600 + 12 * 60), from: now) == "3 h, 12 min")
        #expect(Countdown.text(until: now.addingTimeInterval(45 * 60), from: now) == "45 min")
    }

    @Test func reportsNowWhenStarted() {
        #expect(Countdown.text(until: now, from: now) == "Now")
        #expect(Countdown.text(until: now.addingTimeInterval(-60), from: now) == "Now")
    }
}

@Suite struct CountryFlagTests {
    @Test func mapsKnownCountries() {
        #expect(CountryFlag.emoji(for: "Australia") == "🇦🇺")
        #expect(CountryFlag.emoji(for: "UK") == "🇬🇧")
        #expect(CountryFlag.emoji(for: "USA") == "🇺🇸")
    }

    @Test func fallsBackForUnknownCountry() {
        #expect(CountryFlag.emoji(for: "Atlantis") == CountryFlag.fallback)
    }

    @Test func coversEveryCountryInFixture() throws {
        for weekend in try loadSchedule() {
            #expect(CountryFlag.emoji(for: weekend.circuit.country) != CountryFlag.fallback, "\(weekend.circuit.country)")
        }
    }
}

@Suite struct CircuitMapCoverageTests {
    @Test func everyCircuitInFixtureHasAMap() throws {
        for weekend in try loadSchedule() {
            #expect(CircuitMap.image(for: weekend.circuit.id) != nil, "\(weekend.circuit.id)")
        }
    }

    @Test func unknownCircuitHasNoMap() {
        #expect(CircuitMap.image(for: "atlantis") == nil)
    }
}

@Suite struct DiskCacheTests {
    @Test func roundTripsValues() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = DiskCache(directory: directory)
        let schedule = try loadSchedule()

        cache.write(schedule, key: "schedule")

        #expect(cache.read([RaceWeekend].self, key: "schedule") == schedule)
        #expect(cache.read([RaceWeekend].self, key: "missing") == nil)
    }
}
