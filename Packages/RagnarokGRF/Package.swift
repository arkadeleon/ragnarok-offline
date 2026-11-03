// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokGRF",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokGRF",
            targets: ["RagnarokGRF"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../DataCompression"),
    ],
    targets: [
        .target(
            name: "RagnarokGRF",
            dependencies: [
                "BinaryIO",
                "DataCompression",
            ]
        ),
        .testTarget(
            name: "RagnarokGRFTests",
            dependencies: ["RagnarokGRF"]
        ),
    ]
)
