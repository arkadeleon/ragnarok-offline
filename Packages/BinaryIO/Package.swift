// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BinaryIO",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "BinaryIO",
            targets: ["BinaryIO"]
        ),
    ],
    targets: [
        .target(
            name: "BinaryIO"
        ),
        .testTarget(
            name: "BinaryIOTests",
            dependencies: ["BinaryIO"]
        ),
    ]
)
