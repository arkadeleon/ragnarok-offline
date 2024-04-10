// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ragnarok-offline",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RagnarokOfflineFileFormats",
            targets: ["RagnarokOfflineFileFormats"]),
        .library(
            name: "RagnarokOfflineCrypto",
            targets: ["RagnarokOfflineCrypto"]),
        .library(
            name: "RagnarokOfflineStream",
            targets: ["RagnarokOfflineStream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RagnarokOfflineFileFormats",
            dependencies: [
                "DataCompression",
                "RagnarokOfflineCrypto",
                "RagnarokOfflineStream",
            ]),
        .target(
            name: "RagnarokOfflineCrypto"),
        .target(
            name: "RagnarokOfflineStream"),
        .testTarget(
            name: "RagnarokOfflineFileFormatsTests",
            dependencies: ["RagnarokOfflineFileFormats"]),
    ]
)
