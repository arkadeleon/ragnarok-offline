// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextEncoding",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "TextEncoding",
            targets: ["TextEncoding"]
        ),
    ],
    targets: [
        .target(
            name: "TextEncoding"
        ),
        .testTarget(
            name: "TextEncodingTests",
            dependencies: ["TextEncoding"]
        ),
    ]
)
