// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokDatabase",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokDatabase",
            targets: ["RagnarokDatabase"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../DataCompression"),
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokCore"),
        .package(url: "https://github.com/arkadeleon/swift-rapidyaml.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RagnarokDatabase",
            dependencies: [
                "BinaryIO",
                "DataCompression",
                "RagnarokConstants",
                "RagnarokCore",
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
            ]
        ),
        .testTarget(
            name: "RagnarokDatabaseTests",
            dependencies: ["RagnarokDatabase"]
        ),
    ]
)
