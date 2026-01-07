// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokPackets",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokPackets",
            targets: ["RagnarokPackets"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
    ],
    targets: [
        .target(
            name: "RagnarokPackets",
            dependencies: ["BinaryIO"]
        ),
        .testTarget(
            name: "RagnarokPacketsTests",
            dependencies: ["RagnarokPackets"]
        ),
    ]
)
