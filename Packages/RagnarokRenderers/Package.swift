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
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokRenderAssets"),
        .package(path: "../RagnarokShaders"),
    ],
    targets: [
        .target(
            name: "RagnarokRenderers",
            dependencies: [
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokRenderAssets",
                "RagnarokShaders",
            ]
        ),
        .testTarget(
            name: "RagnarokRenderersTests",
            dependencies: ["RagnarokRenderers"]
        ),
    ]
)
