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
        .package(path: "../GRF"),
        .package(path: "../ImageRendering"),
        .package(path: "../TextEncoding"),
        .package(url: "https://github.com/arkadeleon/swift-lua.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RagnarokResources",
            dependencies: [
                "GRF",
                "ImageRendering",
                "TextEncoding",
                .product(name: "Lua", package: "swift-lua"),
            ]
        ),
        .testTarget(
            name: "RagnarokResourcesTests",
            dependencies: ["RagnarokResources"]
        ),
    ]
)
