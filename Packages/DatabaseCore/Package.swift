// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "DatabaseCore",
            targets: ["DatabaseCore"]
        ),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../Constants"),
        .package(path: "../DataCompression"),
        .package(path: "../PerformanceMetric"),
        .package(url: "https://github.com/arkadeleon/swift-rapidyaml.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "DatabaseCore",
            dependencies: [
                "BinaryIO",
                "Constants",
                "DataCompression",
                "PerformanceMetric",
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
            ]
        ),
        .testTarget(
            name: "DatabaseCoreTests",
            dependencies: ["DatabaseCore"]
        ),
    ]
)
