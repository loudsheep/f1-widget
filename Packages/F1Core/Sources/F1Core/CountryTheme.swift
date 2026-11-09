import Foundation

public struct RGB: Hashable, Sendable {
    public static let black = RGB(hex: 0x000000)
    public static let white = RGB(hex: 0xFFFFFF)

    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    public var relativeLuminance: Double {
        func linear(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }

    public func contrastRatio(with other: RGB) -> Double {
        let lighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    public func mixed(with other: RGB, amount: Double) -> RGB {
        RGB(
            red: red + (other.red - red) * amount,
            green: green + (other.green - green) * amount,
            blue: blue + (other.blue - blue) * amount
        )
    }

    public func vivid() -> RGB {
        let brightest = max(red, green, blue)
        guard brightest > 0 else { return self }
        let scale = 1 / brightest
        return RGB(red: red * scale, green: green * scale, blue: blue * scale)
    }

    public func lightened(toContrast target: Double, against background: RGB = .black) -> RGB {
        var amount = 0.0
        var color = self
        while color.contrastRatio(with: background) < target, amount < 1 {
            amount += 0.05
            color = mixed(with: .white, amount: amount)
        }
        return color
    }
}

public struct CountryTheme: Sendable {
    public static let minimumTextContrast = 10.0
    public static let fallback = CountryTheme(colors: [RGB(hex: 0xE10600)])

    public let colors: [RGB]

    public var glowPrimary: RGB { colors[0] }
    public var glowSecondary: RGB { colors.count > 1 ? colors[1] : colors[0] }

    public var accent: RGB {
        glowPrimary.vivid().lightened(toContrast: Self.minimumTextContrast)
    }

    public static func theme(for country: String) -> CountryTheme {
        palettes[country].map { CountryTheme(colors: $0.map(RGB.init(hex:))) } ?? fallback
    }

    public static func hasTheme(for country: String) -> Bool {
        palettes[country] != nil
    }

    private static let palettes: [String: [UInt32]] = [
        "Australia": [0x1F4FBF, 0xE4002B],
        "Austria": [0xED2939, 0xFFFFFF],
        "Azerbaijan": [0x00B5E2, 0xEF3340, 0x509E2F],
        "Belgium": [0xFAE042, 0xED2939],
        "Brazil": [0x009C3B, 0xFFDF00, 0x002776],
        "Canada": [0xD52B1E, 0xFFFFFF],
        "China": [0xDE2910, 0xFFDE00],
        "Hungary": [0xCD2A3E, 0x436F4D],
        "Italy": [0x009246, 0xCE2B37],
        "Japan": [0xBC002D, 0xFFFFFF],
        "Malaysia": [0xCC0001, 0x010066, 0xFFCC00],
        "Mexico": [0x006847, 0xCE1126],
        "Monaco": [0xCE1126, 0xFFFFFF],
        "Netherlands": [0xAE1C28, 0x21468B],
        "Qatar": [0x8A1538, 0xFFFFFF],
        "Singapore": [0xEF3340, 0xFFFFFF],
        "Spain": [0xAA151B, 0xF1BF00],
        "UAE": [0x00732F, 0xEF3340],
        "UK": [0x1F3F9F, 0xC8102E],
        "USA": [0xB22234, 0x3C3B9E],
    ]
}
