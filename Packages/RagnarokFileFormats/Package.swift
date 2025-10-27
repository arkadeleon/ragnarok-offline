// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokFileFormats",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokFileFormats",
            targets: ["RagnarokFileFormats"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../ImageRendering"),
        .package(path: "../PerformanceMetric"),
    ],
    targets: [
        .target(
            name: "RagnarokFileFormats",
            dependencies: [
                "BinaryIO",
                "ImageRendering",
                "PerformanceMetric",
            ]
        ),
        .testTarget(
            name: "RagnarokFileFormatsTests",
            dependencies: ["RagnarokFileFormats"]
        ),
    ]
)
