// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokRenderers",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokRenderers",
            targets: ["RagnarokRenderers"]
        ),
    ],
    dependencies: [
        .package(path: "../ImageRendering"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokSceneAssets"),
        .package(path: "../RagnarokShaders"),
        .package(path: "../SGLMath"),
    ],
    targets: [
        .target(
            name: "RagnarokRenderers",
            dependencies: [
                "ImageRendering",
                "RagnarokFileFormats",
                "RagnarokSceneAssets",
                "RagnarokShaders",
                "SGLMath",
            ]
        ),
        .testTarget(
            name: "RagnarokRenderersTests",
            dependencies: ["RagnarokRenderers"]
        ),
    ]
)
