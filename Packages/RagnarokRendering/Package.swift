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
            name: "RagnarokRealityRendering",
            targets: ["RagnarokRealityRendering"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokRenderAssets"),
        .package(path: "../RagnarokRenderers"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokShaders"),
    ],
    targets: [
        .target(
            name: "RagnarokRendering",
            dependencies: [
                "RagnarokRenderAssets",
                "RagnarokRealityRendering",
                "RagnarokRenderers",
                "RagnarokShaders",
            ]
        ),
        .target(
            name: "RagnarokRealityRendering",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokRenderAssets",
                "RagnarokResources",
            ]
        ),
        .testTarget(
            name: "RagnarokRealityRenderingTests",
            dependencies: ["RagnarokRealityRendering"]
        ),
    ]
)
