// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokRendering",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokRendering",
            targets: ["RagnarokRendering"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokEffects"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokRenderAssets"),
        .package(path: "../RagnarokShaders"),
    ],
    targets: [
        .target(
            name: "RagnarokRendering",
            dependencies: [
                "RagnarokCore",
                "RagnarokEffects",
                "RagnarokFileFormats",
                "RagnarokRenderAssets",
                "RagnarokShaders",
            ]
        ),
        .testTarget(
            name: "RagnarokRenderingTests",
            dependencies: ["RagnarokRendering"]
        ),
    ]
)
