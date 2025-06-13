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
            name: "ROServer",
            targets: ["ROServer"]),
        .library(
            name: "ROShaders",
            targets: ["ROShaders"]),
    ],
    dependencies: [
        .package(path: "../swift-binary-io"),
        .package(path: "../swift-grf"),
        .package(path: "../../swift-lua"),
        .package(path: "../../swift-rathena"),
        .package(url: "https://github.com/arkadeleon/swift-gzip.git", branch: "main"),
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
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "SwiftGzip", package: "swift-gzip"),
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
                "ROConstants",
                "ROCore",
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ],
            resources: [
                .copy("Resources/db"),
                .copy("Resources/npc"),
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
            ],
            resources: [
                .copy("Resources/cursors.act"),
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
                "ROResources",
            ]),
        .testTarget(
            name: "RONetworkTests",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
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
            ],
            resources: [
                .copy("Resources/data"),
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
            ],
            resources: [
                .copy("Resources/data"),
            ]),
        .target(
            name: "ROServer",
            dependencies: [
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                .product(name: "rAthenaWeb", package: "swift-rathena"),
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
