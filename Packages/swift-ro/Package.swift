// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ro",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RODatabase",
            targets: ["RODatabase"]),
        .library(
            name: "ROGame",
            targets: ["ROGame"]),
        .library(
            name: "RORendering",
            targets: ["RORendering"]),
        .library(
            name: "ROResources",
            targets: ["ROResources"]),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../Constants"),
        .package(path: "../FileFormats"),
        .package(path: "../GRF"),
        .package(path: "../ImageRendering"),
        .package(path: "../MetalRenderers"),
        .package(path: "../NetworkClient"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
        .package(url: "https://github.com/arkadeleon/swift-gzip.git", branch: "main"),
        .package(url: "https://github.com/arkadeleon/swift-lua.git", branch: "master"),
        .package(url: "https://github.com/arkadeleon/swift-rapidyaml.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RODatabase",
            dependencies: [
                "BinaryIO",
                "Constants",
                "PerformanceMetric",
                .product(name: "SwiftGzip", package: "swift-gzip"),
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ]),
        .target(
            name: "ROGame",
            dependencies: [
                "Constants",
                "FileFormats",
                "ImageRendering",
                "MetalRenderers",
                "NetworkClient",
                "PerformanceMetric",
                "RORendering",
                "ROResources",
                "SGLMath",
                "TextEncoding",
            ]),
        .target(
            name: "RORendering",
            dependencies: [
                "Constants",
                "FileFormats",
                "ROResources",
                "TextEncoding",
            ]),
        .testTarget(
            name: "RORenderingTests",
            dependencies: [
                "RORendering",
            ]),
        .target(
            name: "ROResources",
            dependencies: [
                "Constants",
                "GRF",
                "TextEncoding",
                .product(name: "Lua", package: "swift-lua"),
            ],
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "ROResourcesTests",
            dependencies: [
                "Constants",
                "ImageRendering",
                "ROResources",
            ]),
    ]
)
