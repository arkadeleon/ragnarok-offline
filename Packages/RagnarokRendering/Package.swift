// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokRendering",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RagnarokRendering",
            targets: ["RagnarokRendering"]
        ),
        .library(
            name: "RagnarokMetalRendering",
            targets: ["RagnarokMetalRendering"]
        ),
        .library(
            name: "RagnarokRealityRendering",
            targets: ["RagnarokRealityRendering"]
        ),
        .library(
            name: "RagnarokSceneAssets",
            targets: ["RagnarokSceneAssets"]
        ),
        .library(
            name: "RagnarokShaders",
            targets: ["RagnarokShaders"]
        ),
    ],
    dependencies: [
        .package(path: "../ImageRendering"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokResources"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
    ],
    targets: [
        .target(
            name: "RagnarokRendering",
            dependencies: [
                "RagnarokMetalRendering",
                "RagnarokRealityRendering",
                "RagnarokSceneAssets",
                "RagnarokShaders",
            ]
        ),
        .target(
            name: "RagnarokMetalRendering",
            dependencies: [
                "ImageRendering",
                "RagnarokFileFormats",
                "RagnarokSceneAssets",
                "RagnarokShaders",
                "SGLMath",
            ]
        ),
        .target(
            name: "RagnarokRealityRendering",
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
        .target(
            name: "RagnarokSceneAssets",
            dependencies: [
                "ImageRendering",
                "RagnarokFileFormats",
                "RagnarokResources",
                "RagnarokShaders",
                "SGLMath",
                "TextEncoding",
            ]
        ),
        .target(
            name: "RagnarokShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Sprite/SpriteShaders.metal"),
                .process("Tile/TileShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]
        ),
        .testTarget(
            name: "RagnarokMetalRenderingTests",
            dependencies: ["RagnarokMetalRendering"]
        ),
        .testTarget(
            name: "RagnarokRealityRenderingTests",
            dependencies: ["RagnarokRealityRendering"]
        ),
        .testTarget(
            name: "RagnarokSceneAssetsTests",
            dependencies: ["RagnarokSceneAssets"]
        ),
        .testTarget(
            name: "RagnarokShadersTests",
            dependencies: ["RagnarokShaders"]
        ),
    ]
)
