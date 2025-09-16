// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileFormats",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "FileFormats",
            targets: ["FileFormats"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../ImageRendering"),
        .package(path: "../PerformanceMetric"),
    ],
    targets: [
        .target(
            name: "FileFormats",
            dependencies: [
                "BinaryIO",
                "ImageRendering",
                "PerformanceMetric",
            ]
        ),
        .testTarget(
            name: "FileFormatsTests",
            dependencies: ["FileFormats"]
        ),
    ]
)
