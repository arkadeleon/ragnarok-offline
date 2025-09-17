// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameCore",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "GameCore",
            targets: ["GameCore"]
        ),
    ],
    dependencies: [
        .package(path: "../Constants"),
        .package(path: "../FileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../NetworkClient"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../ResourceManagement"),
        .package(path: "../SGLMath"),
        .package(path: "../SpriteRendering"),
        .package(path: "../WorldCamera"),
        .package(path: "../WorldRendering"),
    ],
    targets: [
        .target(
            name: "GameCore",
            dependencies: [
                "Constants",
                "FileFormats",
                "ImageRendering",
                "NetworkClient",
                "PerformanceMetric",
                "ResourceManagement",
                "SGLMath",
                "SpriteRendering",
                "WorldCamera",
                "WorldRendering",
            ]
        ),
        .testTarget(
            name: "GameCoreTests",
            dependencies: ["GameCore"]
        ),
    ]
)
