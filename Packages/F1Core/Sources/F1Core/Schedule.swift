import Foundation

public extension Collection where Element == RaceWeekend {
    func upcomingWeekend(at date: Date) -> RaceWeekend? {
        sorted { $0.round < $1.round }.first { ($0.finish ?? .distantPast) > date }
    }

    func nextSession(at date: Date) -> (weekend: RaceWeekend, session: WeekendSession)? {
        for weekend in sorted(by: { $0.round < $1.round }) {
            if let session = weekend.sessions.first(where: { $0.end > date }) {
                return (weekend, session)
            }
        }
        return nil
    }
}

public extension RaceWeekend {
    func nextSession(at date: Date) -> WeekendSession? {
        sessions.first { $0.end > date }
    }
}

public struct SessionDay: Identifiable, Hashable, Sendable {
    public let day: Date
    public let sessions: [WeekendSession]

    public var id: Date { day }
}

public extension RaceWeekend {
    func sessionsByDay(calendar: Calendar = .current) -> [SessionDay] {
        Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.start) }
            .map { SessionDay(day: $0.key, sessions: $0.value.sorted { $0.start < $1.start }) }
            .sorted { $0.day < $1.day }
    }
}
