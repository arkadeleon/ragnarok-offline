// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokGame",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RagnarokGame",
            targets: ["RagnarokGame"]
        ),
    ],
    dependencies: [
        .package(path: "../ImageRendering"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokLocalization"),
        .package(path: "../RagnarokModels"),
        .package(path: "../RagnarokNetwork"),
        .package(path: "../RagnarokPackets"),
        .package(path: "../RagnarokReality"),
        .package(path: "../RagnarokRenderers"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokSceneAssets"),
        .package(path: "../RagnarokSprite"),
        .package(path: "../SGLMath"),
        .package(path: "../ThumbstickView"),
        .package(path: "../WorldCamera"),
    ],
    targets: [
        .target(
            name: "RagnarokGame",
            dependencies: [
                "ImageRendering",
                "PerformanceMetric",
                "RagnarokConstants",
                "RagnarokFileFormats",
                "RagnarokLocalization",
                "RagnarokModels",
                "RagnarokNetwork",
                "RagnarokPackets",
                "RagnarokReality",
                "RagnarokRenderers",
                "RagnarokResources",
                "RagnarokSceneAssets",
                "RagnarokSprite",
                "SGLMath",
                "ThumbstickView",
                "WorldCamera",
            ]
        ),
        .testTarget(
            name: "RagnarokGameTests",
            dependencies: ["RagnarokGame"]
        ),
    ]
)
