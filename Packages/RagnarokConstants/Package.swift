// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokConstants",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokConstants",
            targets: ["RagnarokConstants"]
        ),
    ],
    targets: [
        .target(
            name: "RagnarokConstants"
        ),
        .testTarget(
            name: "RagnarokConstantsTests",
            dependencies: ["RagnarokConstants"]
        ),
    ]
)
