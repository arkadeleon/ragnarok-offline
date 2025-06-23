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
        .package(path: "../swift-binary-io"),
        .package(url: "https://github.com/arkadeleon/swift-gzip.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "GRF",
            dependencies: [
                .product(name: "BinaryIO", package: "swift-binary-io"),
                .product(name: "SwiftGzip", package: "swift-gzip"),
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
