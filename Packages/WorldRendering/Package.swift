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
        .package(path: "../FileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../MetalRenderers"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../ResourceManagement"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
    ],
    targets: [
        .target(
            name: "WorldRendering",
            dependencies: [
                "FileFormats",
                "ImageRendering",
                "MetalRenderers",
                "PerformanceMetric",
                "ResourceManagement",
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
