import Foundation

public enum SampleData {
    public static var seasonJSON: Data {
        guard
            let url = Bundle.module.url(forResource: "season", withExtension: "json", subdirectory: "SampleData"),
            let data = try? Data(contentsOf: url)
        else { return Data() }
        return data
    }

    public static func season() -> [RaceWeekend] {
        (try? JolpicaClient.decodeSchedule(seasonJSON)) ?? []
    }
}
