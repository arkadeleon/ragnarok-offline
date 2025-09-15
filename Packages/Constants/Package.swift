// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Constants",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Constants",
            targets: ["Constants"]
        ),
    ],
    targets: [
        .target(
            name: "Constants"
        ),
        .testTarget(
            name: "ConstantsTests",
            dependencies: ["Constants"]
        ),
    ]
)
