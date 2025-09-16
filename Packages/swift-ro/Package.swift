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
            name: "RONetwork",
            targets: ["RONetwork"]),
        .library(
            name: "ROPackets",
            targets: ["ROPackets"]),
        .library(
            name: "RORenderers",
            targets: ["RORenderers"]),
        .library(
            name: "RORendering",
            targets: ["RORendering"]),
        .library(
            name: "ROResources",
            targets: ["ROResources"]),
        .library(
            name: "ROShaders",
            targets: ["ROShaders"]),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../Constants"),
        .package(path: "../FileFormats"),
        .package(path: "../GRF"),
        .package(path: "../ImageRendering"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
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
                "PerformanceMetric",
                "RONetwork",
                "RORenderers",
                "RORendering",
                "ROResources",
                "SGLMath",
                "TextEncoding",
            ]),
        .target(
            name: "RONetwork",
            dependencies: [
                "BinaryIO",
                "Constants",
                "ROPackets",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]),
        .testTarget(
            name: "RONetworkTests",
            dependencies: [
                "RONetwork",
            ]),
        .target(
            name: "ROPackets",
            dependencies: [
                "BinaryIO",
            ]),
        .testTarget(
            name: "ROPacketsTests",
            dependencies: [
                "ROPackets",
            ]),
        .target(
            name: "RORenderers",
            dependencies: [
                "FileFormats",
                "ROShaders",
                "SGLMath",
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
        .target(
            name: "ROShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]),
    ]
)
