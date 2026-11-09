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

    @Test func staysOnSessionWhileLive() throws {
        let schedule = try loadSchedule()
        let first = try #require(schedule.first)
        let current = first.sessions[0]
        let during = current.start.addingTimeInterval(30 * 60)
        let next = try #require(schedule.nextSession(at: during))
        #expect(next.session == current)
        #expect(current.isLive(at: during))
    }

    @Test func advancesWhenSessionEnds() throws {
        let schedule = try loadSchedule()
        let first = try #require(schedule.first)
        let next = try #require(schedule.nextSession(at: first.sessions[0].end))
        #expect(next.session == first.sessions[1])
        #expect(!first.sessions[0].isLive(at: first.sessions[0].end))
    }

    @Test func raceLastsTwoHoursAndOthersOne() {
        #expect(SessionKind.race.duration == 2 * 3600)
        for kind in SessionKind.allCases where kind != .race {
            #expect(kind.duration == 3600)
        }
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
    @Test func resolvesIsoCodes() {
        #expect(CountryFlag.isoCode(for: "Australia") == "AU")
        #expect(CountryFlag.isoCode(for: "UK") == "GB")
        #expect(CountryFlag.isoCode(for: "USA") == "US")
        #expect(CountryFlag.isoCode(for: "Atlantis") == nil)
    }

    @Test func unknownCountryHasNoImage() {
        #expect(CountryFlag.image(for: "Atlantis") == nil)
    }

    @Test func everyCountryInFixtureHasFlagAndTheme() throws {
        for weekend in try loadSchedule() {
            let country = weekend.circuit.country
            #expect(CountryFlag.image(for: country) != nil, "flag: \(country)")
            #expect(CountryTheme.hasTheme(for: country), "theme: \(country)")
        }
    }
}

@Suite struct SessionDayTests {
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    @Test func groupsStandardWeekendIntoThreeDays() throws {
        let australia = try #require(try loadSchedule().first { $0.circuit.id == "albert_park" })
        let days = australia.sessionsByDay(calendar: utc)
        #expect(days.map { $0.sessions.map(\.kind) } == [
            [.firstPractice, .secondPractice],
            [.thirdPractice, .qualifying],
            [.race],
        ])
    }

    @Test func groupsSprintWeekendIntoThreeDays() throws {
        let china = try #require(try loadSchedule().first { $0.circuit.id == "shanghai" })
        let days = china.sessionsByDay(calendar: utc)
        #expect(days.count == 3)
        #expect(days.last?.sessions.map(\.kind) == [.race])
    }
}

@Suite struct GrandPrixCodeTests {
    @Test func usesRacingAbbreviations() {
        #expect(CountryFlag.grandPrixCode(for: "Azerbaijan") == "AZE")
        #expect(CountryFlag.grandPrixCode(for: "Netherlands") == "NED")
        #expect(CountryFlag.grandPrixCode(for: "Singapore") == "SIN")
    }

    @Test func fallsBackToFirstThreeLetters() {
        #expect(CountryFlag.grandPrixCode(for: "Atlantis") == "ATL")
    }
}

@Suite struct CountryThemeTests {
    @Test func accentIsReadableOnBlack() throws {
        for weekend in try loadSchedule() {
            let theme = CountryTheme.theme(for: weekend.circuit.country)
            let ratio = theme.accent.contrastRatio(with: .black)
            #expect(ratio >= CountryTheme.minimumTextContrast, "\(weekend.circuit.country): \(ratio)")
        }
    }

    @Test func lighteningNeverChangesAlreadyReadableColors() {
        let color = RGB(hex: 0xFAE042)
        #expect(color.lightened(toContrast: 4.5) == color)
    }

    @Test func contrastRatioMatchesWcagReferenceValues() {
        #expect(abs(RGB.white.contrastRatio(with: .black) - 21) < 0.001)
        #expect(abs(RGB.white.contrastRatio(with: .white) - 1) < 0.001)
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
