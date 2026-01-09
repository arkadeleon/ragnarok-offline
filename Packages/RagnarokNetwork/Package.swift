// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokNetwork",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokNetwork",
            targets: ["RagnarokNetwork"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokModels"),
        .package(path: "../RagnarokPackets"),
    ],
    targets: [
        .target(
            name: "RagnarokNetwork",
            dependencies: [
                "BinaryIO",
                "RagnarokConstants",
                "RagnarokModels",
                "RagnarokPackets",
            ]
        ),
        .testTarget(
            name: "RagnarokNetworkTests",
            dependencies: ["RagnarokNetwork"]
        ),
    ]
)
