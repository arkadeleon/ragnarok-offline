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
        .package(url: "https://github.com/arkadeleon/ragnarok-grf.git", branch: "master"),
        .package(url: "https://github.com/arkadeleon/ragnarok-lua.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RagnarokResources",
            dependencies: [
                "BinaryIO",
                "RagnarokCore",
                .product(name: "RagnarokGRF", package: "ragnarok-grf"),
                .product(name: "RagnarokLua", package: "ragnarok-lua"),
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
