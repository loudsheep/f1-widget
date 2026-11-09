import CoreGraphics

public enum WidgetStyle: String, Sendable, CaseIterable {
    case flag
    case track
}

public enum WidgetAppearance: String, Sendable, CaseIterable {
    case accent
    case monochrome
}

public enum WidgetLayout: Sendable {
    case small
    case medium

    public var size: CGSize {
        switch self {
        case .small: CGSize(width: 158, height: 158)
        case .medium: CGSize(width: 338, height: 158)
        }
    }
}
