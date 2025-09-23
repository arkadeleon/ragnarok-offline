// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResourceManagement",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "ResourceManagement",
            targets: ["ResourceManagement"]
        ),
    ],
    dependencies: [
        .package(path: "../Constants"),
        .package(path: "../GRF"),
        .package(path: "../TextEncoding"),
        .package(url: "https://github.com/arkadeleon/swift-lua.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "ResourceManagement",
            dependencies: [
                "Constants",
                "GRF",
                "TextEncoding",
                .product(name: "Lua", package: "swift-lua"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "ResourceManagementTests",
            dependencies: ["ResourceManagement"]
        ),
    ]
)
