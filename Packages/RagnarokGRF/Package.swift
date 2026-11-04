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
            name: "CRagnarokGRF",
            exclude: ["xxhash/LICENSE"]
        ),
        .target(
            name: "RagnarokGRF",
            dependencies: [
                "BinaryIO",
                "CRagnarokGRF",
                "DataCompression",
            ]
        ),
        .testTarget(
            name: "RagnarokGRFTests",
            dependencies: ["RagnarokGRF"]
        ),
    ]
)
