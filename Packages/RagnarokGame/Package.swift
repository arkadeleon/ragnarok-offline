// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokGame",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RagnarokGame",
            targets: ["RagnarokGame"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokLocalization"),
        .package(path: "../RagnarokModels"),
        .package(path: "../RagnarokNetwork"),
        .package(path: "../RagnarokPackets"),
        .package(path: "../RagnarokReality"),
        .package(path: "../RagnarokRenderAssets"),
        .package(path: "../RagnarokRenderers"),
        .package(path: "../RagnarokResources"),
        .package(path: "../RagnarokShaders"),
        .package(path: "../RagnarokSprite"),
        .package(path: "../ThumbstickView"),
        .package(path: "../WorldCamera"),
    ],
    targets: [
        .target(
            name: "RagnarokGame",
            dependencies: [
                "RagnarokConstants",
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokLocalization",
                "RagnarokModels",
                "RagnarokNetwork",
                "RagnarokPackets",
                "RagnarokReality",
                "RagnarokRenderAssets",
                "RagnarokRenderers",
                "RagnarokResources",
                "RagnarokShaders",
                "RagnarokSprite",
                "ThumbstickView",
                "WorldCamera",
            ]
        ),
        .testTarget(
            name: "RagnarokGameTests",
            dependencies: ["RagnarokGame"]
        ),
    ]
)
