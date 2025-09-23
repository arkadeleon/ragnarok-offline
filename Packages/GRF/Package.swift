// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GRF",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "GRF",
            targets: ["GRF"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../DataCompression"),
    ],
    targets: [
        .target(
            name: "GRF",
            dependencies: [
                "BinaryIO",
                "DataCompression",
            ]
        ),
        .testTarget(
            name: "GRFTests",
            dependencies: ["GRF"],
            resources: [
                .copy("Resources/data"),
                .copy("Resources/test102.grf"),
                .copy("Resources/test103.grf"),
                .copy("Resources/test200.grf"),
            ]
        ),
    ]
)
