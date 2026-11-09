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
