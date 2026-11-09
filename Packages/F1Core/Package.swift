// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "F1Core",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "F1Core", targets: ["F1Core"]),
    ],
    targets: [
        .target(
            name: "F1Core",
            resources: [
                .copy("Resources/CircuitMaps"),
                .copy("Resources/Flags"),
            ]
        ),
        .testTarget(
            name: "F1CoreTests",
            dependencies: ["F1Core"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
