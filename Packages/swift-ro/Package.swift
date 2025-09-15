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
            name: "ROCore",
            targets: ["ROCore"]),
        .library(
            name: "RODatabase",
            targets: ["RODatabase"]),
        .library(
            name: "ROFileFormats",
            targets: ["ROFileFormats"]),
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
        .package(path: "../GRF"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/arkadeleon/swift-gzip.git", branch: "main"),
        .package(url: "https://github.com/arkadeleon/swift-lua.git", branch: "master"),
        .package(url: "https://github.com/arkadeleon/swift-rapidyaml.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "ROConstants"),
        .target(
            name: "ROCore"),
        .target(
            name: "RODatabase",
            dependencies: [
                "BinaryIO",
                "ROConstants",
                "ROCore",
                .product(name: "SwiftGzip", package: "swift-gzip"),
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ]),
        .target(
            name: "ROFileFormats",
            dependencies: [
                "BinaryIO",
                "ROCore",
            ]),
        .testTarget(
            name: "ROFileFormatsTests",
            dependencies: [
                "ROFileFormats"
            ]),
        .target(
            name: "ROGame",
            dependencies: [
                "ROConstants",
                "ROCore",
                "ROFileFormats",
                "RONetwork",
                "RORenderers",
                "RORendering",
                "ROResources",
            ]),
        .target(
            name: "RONetwork",
            dependencies: [
                "BinaryIO",
                "ROConstants",
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
                "ROCore",
                "ROFileFormats",
                "ROShaders",
            ]),
        .target(
            name: "RORendering",
            dependencies: [
                "ROConstants",
                "ROCore",
                "ROFileFormats",
                "ROResources",
            ]),
        .testTarget(
            name: "RORenderingTests",
            dependencies: [
                "RORendering",
            ]),
        .target(
            name: "ROResources",
            dependencies: [
                "GRF",
                "ROConstants",
                "ROCore",
                .product(name: "Lua", package: "swift-lua"),
            ],
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "ROResourcesTests",
            dependencies: [
                "ROConstants",
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
