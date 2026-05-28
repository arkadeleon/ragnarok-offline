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
        .package(path: "../RagnarokConstants"),
        .package(path: "../RagnarokCore"),
        .package(url: "https://github.com/arkadeleon/swift-rapidyaml.git", branch: "master"),
        .package(url: "https://github.com/mihai8804858/swift-gzip", branch: "main"),
    ],
    targets: [
        .target(
            name: "RagnarokDatabase",
            dependencies: [
                "BinaryIO",
                "RagnarokConstants",
                "RagnarokCore",
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
                .product(name: "SwiftGzip", package: "swift-gzip"),
            ]
        ),
        .testTarget(
            name: "RagnarokDatabaseTests",
            dependencies: ["RagnarokDatabase"]
        ),
    ]
)
