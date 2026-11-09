import Foundation

public struct JolpicaClient: Sendable {
    public static let baseURL = URL(string: "https://api.jolpi.ca/ergast/f1")!

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func schedule(season: String = "current") async throws -> [RaceWeekend] {
        let url = Self.baseURL
            .appending(path: "\(season).json")
            .appending(queryItems: [URLQueryItem(name: "limit", value: "100")])
        return try Self.decodeSchedule(try await data(from: url))
    }

    public func results(season: String = "current", round: String = "last") async throws -> RaceResults? {
        let url = Self.baseURL.appending(path: "\(season)/\(round)/results.json")
        return try Self.decodeResults(try await data(from: url))
    }

    private func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

extension JolpicaClient {
    static func decodeSchedule(_ data: Data) throws -> [RaceWeekend] {
        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        return try envelope.mrData.raceTable.races.map { try $0.weekend() }
    }

    static func decodeResults(_ data: Data) throws -> RaceResults? {
        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        guard let race = envelope.mrData.raceTable.races.first else { return nil }
        return RaceResults(
            season: try race.intSeason(),
            round: try race.intRound(),
            raceName: race.raceName,
            entries: (race.results ?? []).compactMap { $0.driverResult() }
        )
    }
}

private struct Envelope: Decodable {
    let mrData: MRData

    enum CodingKeys: String, CodingKey { case mrData = "MRData" }
}

private struct MRData: Decodable {
    let raceTable: RaceTable

    enum CodingKeys: String, CodingKey { case raceTable = "RaceTable" }
}

private struct RaceTable: Decodable {
    let races: [WireRace]

    enum CodingKeys: String, CodingKey { case races = "Races" }
}

private struct WireSlot: Decodable {
    let date: String
    let time: String?

    func parsed() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: "\(date)T\(time ?? "00:00:00Z")")
    }
}

private struct WireRace: Decodable {
    let season: String
    let round: String
    let raceName: String
    let circuit: WireCircuit
    let date: String
    let time: String?
    let firstPractice: WireSlot?
    let secondPractice: WireSlot?
    let thirdPractice: WireSlot?
    let sprintQualifying: WireSlot?
    let sprint: WireSlot?
    let qualifying: WireSlot?
    let results: [WireResult]?

    enum CodingKeys: String, CodingKey {
        case season, round, raceName, date, time
        case circuit = "Circuit"
        case firstPractice = "FirstPractice"
        case secondPractice = "SecondPractice"
        case thirdPractice = "ThirdPractice"
        case sprintQualifying = "SprintQualifying"
        case sprint = "Sprint"
        case qualifying = "Qualifying"
        case results = "Results"
    }

    func intSeason() throws -> Int { try Self.int(season) }
    func intRound() throws -> Int { try Self.int(round) }

    func weekend() throws -> RaceWeekend {
        let slots: [(SessionKind, WireSlot?)] = [
            (.firstPractice, firstPractice),
            (.secondPractice, secondPractice),
            (.thirdPractice, thirdPractice),
            (.sprintQualifying, sprintQualifying),
            (.sprint, sprint),
            (.qualifying, qualifying),
            (.race, WireSlot(date: date, time: time)),
        ]
        return RaceWeekend(
            season: try intSeason(),
            round: try intRound(),
            name: raceName,
            circuit: circuit.model,
            sessions: slots.compactMap { kind, slot in
                slot?.parsed().map { WeekendSession(kind: kind, start: $0) }
            }
        )
    }

    private static func int(_ value: String) throws -> Int {
        guard let number = Int(value) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Not an integer: \(value)"))
        }
        return number
    }
}

private struct WireCircuit: Decodable {
    let circuitId: String
    let circuitName: String
    let location: Location

    enum CodingKeys: String, CodingKey {
        case circuitId, circuitName
        case location = "Location"
    }

    struct Location: Decodable {
        let locality: String
        let country: String
    }

    var model: Circuit {
        Circuit(id: circuitId, name: circuitName, locality: location.locality, country: location.country)
    }
}

private struct WireResult: Decodable {
    let position: String
    let positionText: String
    let points: String
    let grid: String
    let status: String
    let driver: Driver
    let constructor: Constructor
    let time: TimeValue?

    enum CodingKeys: String, CodingKey {
        case position, positionText, points, grid, status
        case driver = "Driver"
        case constructor = "Constructor"
        case time = "Time"
    }

    struct Driver: Decodable {
        let code: String?
        let givenName: String
        let familyName: String
    }

    struct Constructor: Decodable {
        let name: String
    }

    struct TimeValue: Decodable {
        let time: String
    }

    func driverResult() -> DriverResult? {
        guard let position = Int(position) else { return nil }
        return DriverResult(
            position: position,
            positionText: positionText,
            driverName: "\(driver.givenName) \(driver.familyName)",
            driverCode: driver.code,
            constructor: constructor.name,
            grid: Int(grid) ?? 0,
            time: time?.time,
            status: status,
            points: Double(points) ?? 0
        )
    }
}
