import AppKit

public enum CircuitMap {
    public static func url(for circuitId: String) -> URL? {
        Bundle.module.url(forResource: circuitId, withExtension: "svg", subdirectory: "CircuitMaps")
    }

    public static func image(for circuitId: String) -> NSImage? {
        guard let url = url(for: circuitId), let image = NSImage(contentsOf: url) else { return nil }
        image.isTemplate = true
        return image
    }
}
