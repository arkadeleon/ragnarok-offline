// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokScript",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokScript",
            targets: ["RagnarokScript"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokResources"),
        .package(url: "https://github.com/arkadeleon/ragnarok-lua.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RagnarokScript",
            dependencies: [
                "RagnarokResources",
                .product(name: "RagnarokLua", package: "ragnarok-lua"),
            ]
        ),
        .testTarget(
            name: "RagnarokScriptTests",
            dependencies: [
                "RagnarokCore",
                "RagnarokScript",
            ]
        ),
    ]
)
