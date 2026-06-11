// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokRenderAssetIO",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokRenderAssetIO",
            targets: ["RagnarokRenderAssetIO"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokRenderAssets"),
        .package(path: "../RagnarokResources"),
    ],
    targets: [
        .target(
            name: "RagnarokRenderAssetIO",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokRenderAssets",
                "RagnarokResources",
            ]
        ),
        .testTarget(
            name: "RagnarokRenderAssetIOTests",
            dependencies: ["RagnarokRenderAssetIO"]
        ),
    ]
)
