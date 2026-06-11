// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokRenderAssets",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokRenderAssets",
            targets: ["RagnarokRenderAssets"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokShaders"),
    ],
    targets: [
        .target(
            name: "RagnarokRenderAssets",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokShaders",
            ]
        ),
        .testTarget(
            name: "RagnarokRenderAssetsTests",
            dependencies: ["RagnarokRenderAssets"]
        ),
    ]
)
