// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorldRendering",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "WorldRendering",
            targets: ["WorldRendering"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../MetalRenderers"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokResources"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
    ],
    targets: [
        .target(
            name: "WorldRendering",
            dependencies: [
                "RagnarokFileFormats",
                "ImageRendering",
                "MetalRenderers",
                "PerformanceMetric",
                "RagnarokResources",
                "SGLMath",
                "TextEncoding",
            ]
        ),
        .testTarget(
            name: "WorldRenderingTests",
            dependencies: ["WorldRendering"]
        ),
    ]
)
