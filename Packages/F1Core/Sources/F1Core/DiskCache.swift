import Foundation

public struct DiskCache: Sendable {
    private let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    public static var shared: DiskCache {
        DiskCache(directory: AppGroup.cacheDirectory)
    }

    public func read<Value: Decodable>(_ type: Value.Type, key: String) -> Value? {
        guard let data = try? Data(contentsOf: fileURL(for: key)) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    public func write(_ value: some Encodable, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: fileURL(for: key), options: .atomic)
    }

    private func fileURL(for key: String) -> URL {
        directory.appending(path: "\(key).json")
    }
}

public enum AppGroup {
    public static let identifier = "group.dev.loudsheep.f1widget"

    public static var cacheDirectory: URL {
        let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
            ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return base.appending(path: "F1Cache")
    }
}
