// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-binary-io",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
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
