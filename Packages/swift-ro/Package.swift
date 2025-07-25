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
        .package(path: "../swift-binary-io"),
        .package(path: "../swift-grf"),
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
                .product(name: "BinaryIO", package: "swift-binary-io"),
                .product(name: "SwiftGzip", package: "swift-gzip"),
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
                "ROConstants",
                "ROCore",
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ]),
        .target(
            name: "ROFileFormats",
            dependencies: [
                .product(name: "BinaryIO", package: "swift-binary-io"),
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
                .product(name: "BinaryIO", package: "swift-binary-io"),
                "ROConstants",
                "ROPackets",
            ]),
        .testTarget(
            name: "RONetworkTests",
            dependencies: [
                "RONetwork",
            ]),
        .target(
            name: "ROPackets",
            dependencies: [
                .product(name: "BinaryIO", package: "swift-binary-io"),
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
                .product(name: "GRF", package: "swift-grf"),
                .product(name: "Lua", package: "swift-lua"),
                "ROConstants",
                "ROCore",
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
