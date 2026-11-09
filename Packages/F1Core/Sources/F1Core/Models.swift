import Foundation

public struct Circuit: Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let locality: String
    public let country: String

    public init(id: String, name: String, locality: String, country: String) {
        self.id = id
        self.name = name
        self.locality = locality
        self.country = country
    }
}

public enum SessionKind: String, Codable, CaseIterable, Sendable {
    case firstPractice
    case secondPractice
    case thirdPractice
    case sprintQualifying
    case sprint
    case qualifying
    case race

    public var title: String {
        switch self {
        case .firstPractice: "Practice 1"
        case .secondPractice: "Practice 2"
        case .thirdPractice: "Practice 3"
        case .sprintQualifying: "Sprint Qualifying"
        case .sprint: "Sprint"
        case .qualifying: "Qualifying"
        case .race: "Race"
        }
    }

    public var duration: TimeInterval {
        self == .race ? 2 * 60 * 60 : 60 * 60
    }

    public var shortTitle: String {
        switch self {
        case .firstPractice: "FP1"
        case .secondPractice: "FP2"
        case .thirdPractice: "FP3"
        case .sprintQualifying: "SQ"
        case .sprint: "Sprint"
        case .qualifying: "Quali"
        case .race: "Race"
        }
    }
}

public struct WeekendSession: Codable, Hashable, Sendable, Identifiable {
    public let kind: SessionKind
    public let start: Date

    public var id: SessionKind { kind }

    public var end: Date { start.addingTimeInterval(kind.duration) }

    public func isLive(at date: Date) -> Bool {
        start <= date && date < end
    }

    public init(kind: SessionKind, start: Date) {
        self.kind = kind
        self.start = start
    }
}

public struct RaceWeekend: Codable, Hashable, Sendable, Identifiable {
    public let season: Int
    public let round: Int
    public let name: String
    public let circuit: Circuit
    public let sessions: [WeekendSession]

    public var id: String { "\(season)-\(round)" }

    public var raceStart: Date? {
        sessions.first { $0.kind == .race }?.start
    }

    public var firstSessionStart: Date? {
        sessions.first?.start
    }

    public var finish: Date? {
        sessions.first { $0.kind == .race }?.end
    }

    public init(season: Int, round: Int, name: String, circuit: Circuit, sessions: [WeekendSession]) {
        self.season = season
        self.round = round
        self.name = name
        self.circuit = circuit
        self.sessions = sessions.sorted { $0.start < $1.start }
    }
}

public struct DriverResult: Codable, Hashable, Sendable, Identifiable {
    public let position: Int
    public let positionText: String
    public let driverName: String
    public let driverCode: String?
    public let constructor: String
    public let grid: Int
    public let time: String?
    public let status: String
    public let points: Double

    public var id: String { "\(position)-\(driverName)" }

    public init(
        position: Int,
        positionText: String,
        driverName: String,
        driverCode: String?,
        constructor: String,
        grid: Int,
        time: String?,
        status: String,
        points: Double
    ) {
        self.position = position
        self.positionText = positionText
        self.driverName = driverName
        self.driverCode = driverCode
        self.constructor = constructor
        self.grid = grid
        self.time = time
        self.status = status
        self.points = points
    }
}

public struct RaceResults: Codable, Hashable, Sendable {
    public let season: Int
    public let round: Int
    public let raceName: String
    public let entries: [DriverResult]

    public init(season: Int, round: Int, raceName: String, entries: [DriverResult]) {
        self.season = season
        self.round = round
        self.raceName = raceName
        self.entries = entries
    }
}
