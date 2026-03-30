// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokSceneAssets",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RagnarokSceneAssets",
            targets: ["RagnarokSceneAssets"]
        ),
    ],
    dependencies: [
        .package(path: "../ImageRendering"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokShaders"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
    ],
    targets: [
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
        .testTarget(
            name: "RagnarokSceneAssetsTests",
            dependencies: ["RagnarokSceneAssets"]
        ),
    ]
)
