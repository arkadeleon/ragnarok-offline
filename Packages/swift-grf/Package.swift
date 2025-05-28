// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-grf",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "GRF",
            targets: ["GRF"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
        .package(path: "../swift-binary-io"),
    ],
    targets: [
        .target(
            name: "GRF",
            dependencies: [
                "DataCompression",
                .product(name: "BinaryIO", package: "swift-binary-io"),
            ]
        ),
        .testTarget(
            name: "GRFTests",
            dependencies: ["GRF"],
            resources: [
                .copy("Resources/data"),
                .copy("Resources/test.grf"),
            ]
        ),
    ]
)
