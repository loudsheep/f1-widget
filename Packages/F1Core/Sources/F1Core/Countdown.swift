import Foundation

public enum Countdown {
    public static func text(until target: Date, from now: Date) -> String {
        let minutes = Int(target.timeIntervalSince(now) / 60)
        guard minutes > 0 else { return "Now" }

        let days = minutes / (24 * 60)
        let hours = (minutes / 60) % 24
        let remainingMinutes = minutes % 60

        if days > 0 { return "\(days) d, \(hours) h" }
        if hours > 0 { return "\(hours) h, \(remainingMinutes) min" }
        return "\(remainingMinutes) min"
    }
}
