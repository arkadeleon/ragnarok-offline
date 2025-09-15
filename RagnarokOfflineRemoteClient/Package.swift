// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ragnarok-offline-remote-client",
    platforms: [
       .macOS(.v15),
    ],
    dependencies: [
        .package(path: "../Packages/GRF"),
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    ],
    targets: [
        .executableTarget(
            name: "RagnarokOfflineRemoteClient",
            dependencies: [
                "GRF",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "RagnarokOfflineRemoteClientTests",
            dependencies: [
                .target(name: "RagnarokOfflineRemoteClient"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
