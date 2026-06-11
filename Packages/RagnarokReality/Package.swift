// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokReality",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RagnarokReality",
            targets: ["RagnarokReality"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokRenderAssets"),
        .package(path: "../RagnarokResources"),
    ],
    targets: [
        .target(
            name: "RagnarokReality",
            dependencies: [
                "RagnarokCore",
                "RagnarokRenderAssets",
                "RagnarokResources",
            ]
        ),
        .testTarget(
            name: "RagnarokRealityTests",
            dependencies: ["RagnarokReality"]
        ),
    ]
)
