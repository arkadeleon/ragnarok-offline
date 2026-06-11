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
            name: "RagnarokRenderAssets",
            targets: ["RagnarokRenderAssets"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokShaders"),
    ],
    targets: [
        .target(
            name: "RagnarokRendering",
            dependencies: [
                "RagnarokMetalRendering",
                "RagnarokRealityRendering",
                "RagnarokRenderAssets",
                "RagnarokShaders",
            ]
        ),
        .target(
            name: "RagnarokMetalRendering",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokRenderAssets",
                "RagnarokShaders",
            ]
        ),
        .target(
            name: "RagnarokRealityRendering",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokResources",
                "RagnarokRenderAssets",
            ]
        ),
        .target(
            name: "RagnarokRenderAssets",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokResources",
                "RagnarokShaders",
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
            name: "RagnarokRenderAssetsTests",
            dependencies: ["RagnarokRenderAssets"]
        ),
    ]
)
