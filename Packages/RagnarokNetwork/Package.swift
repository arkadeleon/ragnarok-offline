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
        .package(path: "../RagnarokPackets"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "RagnarokNetwork",
            dependencies: [
                "BinaryIO",
                "RagnarokConstants",
                "RagnarokPackets",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .testTarget(
            name: "RagnarokNetworkTests",
            dependencies: ["RagnarokNetwork"]
        ),
    ]
)
