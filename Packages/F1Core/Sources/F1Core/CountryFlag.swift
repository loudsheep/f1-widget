import Foundation

public enum CountryFlag {
    public static let fallback = "🌐"

    public static func emoji(for country: String) -> String {
        guard let code = isoCodes[country] else { return fallback }
        return code.unicodeScalars
            .compactMap { Unicode.Scalar(0x1F1E6 + $0.value - 65) }
            .map { String($0) }
            .joined()
    }

    private static let isoCodes: [String: String] = [
        "Argentina": "AR",
        "Australia": "AU",
        "Austria": "AT",
        "Azerbaijan": "AZ",
        "Bahrain": "BH",
        "Belgium": "BE",
        "Brazil": "BR",
        "Canada": "CA",
        "China": "CN",
        "France": "FR",
        "Germany": "DE",
        "Hungary": "HU",
        "India": "IN",
        "Italy": "IT",
        "Japan": "JP",
        "Korea": "KR",
        "Malaysia": "MY",
        "Mexico": "MX",
        "Monaco": "MC",
        "Morocco": "MA",
        "Netherlands": "NL",
        "Portugal": "PT",
        "Qatar": "QA",
        "Russia": "RU",
        "Saudi Arabia": "SA",
        "Singapore": "SG",
        "South Korea": "KR",
        "Spain": "ES",
        "Sweden": "SE",
        "Switzerland": "CH",
        "Turkey": "TR",
        "UAE": "AE",
        "UK": "GB",
        "USA": "US",
        "Vietnam": "VN",
    ]
}
