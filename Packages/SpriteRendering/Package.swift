// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpriteRendering",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SpriteRendering",
            targets: ["SpriteRendering"]
        ),
    ],
    dependencies: [
        .package(path: "../Constants"),
        .package(path: "../FileFormats"),
        .package(path: "../ResourceManagement"),
        .package(path: "../TextEncoding"),
    ],
    targets: [
        .target(
            name: "SpriteRendering",
            dependencies: [
                "Constants",
                "FileFormats",
                "ResourceManagement",
                "TextEncoding",
            ]
        ),
        .testTarget(
            name: "SpriteRenderingTests",
            dependencies: ["SpriteRendering"]
        ),
    ]
)
