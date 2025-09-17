// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataCompression",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "DataCompression",
            targets: ["DataCompression"]
        ),
    ],
    targets: [
        .systemLibrary(
            name: "CZlib",
            pkgConfig: "libz",
            providers: [
                .apt(["libz-dev"])
            ]
        ),
        .target(
            name: "DataCompression",
            dependencies: ["CZlib"]
        ),
        .testTarget(
            name: "DataCompressionTests",
            dependencies: ["DataCompression"]
        ),
    ]
)
