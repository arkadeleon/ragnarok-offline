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
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokSceneAssets"),
        .package(path: "../SGLMath"),
    ],
    targets: [
        .target(
            name: "RagnarokReality",
            dependencies: [
                "PerformanceMetric",
                "RagnarokFileFormats",
                .target(
                    name: "RagnarokRealitySurfaceShaders",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                "RagnarokResources",
                "RagnarokSceneAssets",
                "SGLMath",
            ]
        ),
        .target(
            name: "RagnarokRealitySurfaceShaders",
            resources: [
                .process("SurfaceShaders.metal"),
            ]
        ),
        .testTarget(
            name: "RagnarokRealityTests",
            dependencies: ["RagnarokReality"]
        ),
    ]
)
