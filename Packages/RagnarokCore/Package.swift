// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokCore",
            targets: ["RagnarokCore"]
        ),
    ],
    targets: [
        .target(
            name: "RagnarokCore"
        ),
        .testTarget(
            name: "RagnarokCoreTests",
            dependencies: ["RagnarokCore"]
        ),
    ]
)
