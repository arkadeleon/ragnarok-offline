// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokSprite",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokSprite",
            targets: ["RagnarokSprite"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokCore"),
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../RagnarokResources"),
    ],
    targets: [
        .target(
            name: "RagnarokSprite",
            dependencies: [
                "RagnarokConstants",
                "RagnarokCore",
                "RagnarokFileFormats",
                "RagnarokResources",
            ]
        ),
        .testTarget(
            name: "RagnarokSpriteTests",
            dependencies: ["RagnarokSprite"]
        ),
    ]
)
