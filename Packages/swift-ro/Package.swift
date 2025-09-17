// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ro",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "ROGame",
            targets: ["ROGame"]),
    ],
    dependencies: [
        .package(path: "../Constants"),
        .package(path: "../FileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../MetalRenderers"),
        .package(path: "../NetworkClient"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../ResourceManagement"),
        .package(path: "../SGLMath"),
        .package(path: "../SpriteRendering"),
        .package(path: "../WorldRendering"),
    ],
    targets: [
        .target(
            name: "ROGame",
            dependencies: [
                "Constants",
                "FileFormats",
                "ImageRendering",
                "MetalRenderers",
                "NetworkClient",
                "PerformanceMetric",
                "ResourceManagement",
                "SGLMath",
                "SpriteRendering",
                "WorldRendering",
            ]),
    ]
)
