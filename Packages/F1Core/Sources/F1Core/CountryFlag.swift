import AppKit
import SwiftUI

public enum CountryFlag {
    public static func isoCode(for country: String) -> String? {
        isoCodes[country]
    }

    public static func grandPrixCode(for country: String) -> String {
        gpCodes[country] ?? String(country.prefix(3)).uppercased()
    }

    public static func url(for country: String) -> URL? {
        guard let code = isoCode(for: country) else { return nil }
        return Bundle.module.url(forResource: code.lowercased(), withExtension: "svg", subdirectory: "Flags")
    }

    public static func image(for country: String) -> NSImage? {
        guard let url = url(for: country) else { return nil }
        return NSImage(contentsOf: url)
    }

    private static let gpCodes: [String: String] = [
        "Argentina": "ARG",
        "Australia": "AUS",
        "Austria": "AUT",
        "Azerbaijan": "AZE",
        "Bahrain": "BHR",
        "Belgium": "BEL",
        "Brazil": "BRA",
        "Canada": "CAN",
        "China": "CHN",
        "France": "FRA",
        "Germany": "GER",
        "Hungary": "HUN",
        "India": "IND",
        "Italy": "ITA",
        "Japan": "JPN",
        "Korea": "KOR",
        "Malaysia": "MAS",
        "Mexico": "MEX",
        "Monaco": "MON",
        "Morocco": "MAR",
        "Netherlands": "NED",
        "Portugal": "POR",
        "Qatar": "QAT",
        "Russia": "RUS",
        "Saudi Arabia": "KSA",
        "Singapore": "SIN",
        "South Korea": "KOR",
        "Spain": "ESP",
        "Sweden": "SWE",
        "Switzerland": "SUI",
        "Turkey": "TUR",
        "UAE": "UAE",
        "UK": "GBR",
        "USA": "USA",
        "Vietnam": "VIE",
    ]

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

public struct FlagView: View {
    private let country: String
    private let width: CGFloat

    public init(country: String, width: CGFloat) {
        self.country = country
        self.width = width
    }

    public var body: some View {
        Group {
            if let image = CountryFlag.image(for: country) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(4 / 3, contentMode: .fit)
            } else {
                Image(systemName: "flag.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(width * 0.15)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: width, height: width * 3 / 4)
        .clipShape(RoundedRectangle(cornerRadius: width * 0.1, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: width * 0.1, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 0.5)
        }
    }
}
