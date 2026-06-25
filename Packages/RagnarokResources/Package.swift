// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokResources",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokResources",
            targets: ["RagnarokResources"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../RagnarokCore"),
    ],
    targets: [
        .target(
            name: "RagnarokResources",
            dependencies: [
                "BinaryIO",
                "RagnarokCore",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "RagnarokResourcesTests",
            dependencies: ["RagnarokResources"]
        ),
    ]
)
