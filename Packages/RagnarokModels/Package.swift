// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokModels",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokModels",
            targets: ["RagnarokModels"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokPackets"),
    ],
    targets: [
        .target(
            name: "RagnarokModels",
            dependencies: [
                "RagnarokConstants",
                "RagnarokPackets",
            ]
        ),
        .testTarget(
            name: "RagnarokModelsTests",
            dependencies: ["RagnarokModels"]
        ),
    ]
)
