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
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../RagnarokNetwork"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokResources"),
        .package(path: "../SGLMath"),
        .package(path: "../RagnarokSprite"),
        .package(path: "../WorldCamera"),
        .package(path: "../RagnarokReality"),
    ],
    targets: [
        .target(
            name: "RagnarokGame",
            dependencies: [
                "RagnarokConstants",
                "RagnarokFileFormats",
                "ImageRendering",
                "RagnarokNetwork",
                "PerformanceMetric",
                "RagnarokResources",
                "SGLMath",
                "RagnarokSprite",
                "WorldCamera",
                "RagnarokReality",
            ]
        ),
        .testTarget(
            name: "RagnarokGameTests",
            dependencies: ["RagnarokGame"]
        ),
    ]
)
