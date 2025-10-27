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
        .package(path: "../RagnarokNetwork"),
        .package(path: "../RagnarokReality"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokSprite"),
        .package(path: "../SGLMath"),
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
                "RagnarokNetwork",
                "RagnarokReality",
                "RagnarokResources",
                "RagnarokSprite",
                "SGLMath",
                "WorldCamera",
            ]
        ),
        .testTarget(
            name: "RagnarokGameTests",
            dependencies: ["RagnarokGame"]
        ),
    ]
)
