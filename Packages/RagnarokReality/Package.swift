// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokReality",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RagnarokReality",
            targets: ["RagnarokReality"]
        ),
    ],
    dependencies: [
        .package(path: "../ImageRendering"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokRenderers"),
        .package(path: "../RagnarokResources"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
    ],
    targets: [
        .target(
            name: "RagnarokReality",
            dependencies: [
                "ImageRendering",
                "PerformanceMetric",
                "RagnarokFileFormats",
                "RagnarokRenderers",
                "RagnarokResources",
                "SGLMath",
                "TextEncoding",
            ]
        ),
        .testTarget(
            name: "RagnarokRealityTests",
            dependencies: ["RagnarokReality"]
        ),
    ]
)
