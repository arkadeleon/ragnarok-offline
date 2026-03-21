// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokSceneAssets",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
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
        .package(path: "../RagnarokRenderers"),
        .package(path: "../RagnarokResources"),
    ],
    targets: [
        .target(
            name: "RagnarokSceneAssets",
            dependencies: [
                "ImageRendering",
                "RagnarokFileFormats",
                "RagnarokRenderers",
                "RagnarokResources",
            ]
        ),
        .testTarget(
            name: "RagnarokSceneAssetsTests",
            dependencies: ["RagnarokSceneAssets"]
        ),
    ]
)
