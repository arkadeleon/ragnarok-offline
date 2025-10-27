// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkClient",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "NetworkClient",
            targets: ["NetworkClient"]
        ),
        .library(
            name: "NetworkPackets",
            targets: ["NetworkPackets"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../RagnarokConstants"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NetworkClient",
            dependencies: [
                "BinaryIO",
                "RagnarokConstants",
                "NetworkPackets",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(
            name: "NetworkPackets",
            dependencies: ["BinaryIO"]
        ),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"]
        ),
        .testTarget(
            name: "NetworkPacketsTests",
            dependencies: ["NetworkPackets"]
        ),
    ]
)
