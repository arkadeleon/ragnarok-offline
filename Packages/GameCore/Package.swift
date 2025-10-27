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
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../RagnarokNetwork"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokResources"),
        .package(path: "../SGLMath"),
        .package(path: "../SpriteRendering"),
        .package(path: "../WorldCamera"),
        .package(path: "../WorldRendering"),
    ],
    targets: [
        .target(
            name: "GameCore",
            dependencies: [
                "RagnarokConstants",
                "RagnarokFileFormats",
                "ImageRendering",
                "RagnarokNetwork",
                "PerformanceMetric",
                "RagnarokResources",
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
