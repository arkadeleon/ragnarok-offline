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
        .package(path: "../../swift-lua"),
        .package(path: "../../swift-rathena"),
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
    ],
    targets: [
        .target(
            name: "ROConstants"),
        .target(
            name: "ROCore"),
        .target(
            name: "RODatabase",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                .product(name: "ryml", package: "swift-rathena"),
                "DataCompression",
                "ROConstants",
                "ROCore",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROFileFormats",
            dependencies: [
                "DataCompression",
                "ROCore",
            ]),
        .testTarget(
            name: "ROFileFormatsTests",
            dependencies: [
                "ROFileFormats"
            ],
            resources: [
                .copy("Resources/data"),
                .copy("Resources/test.grf"),
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
        .testTarget(
            name: "ROGameTests",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                "RODatabase",
                "ROGame",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "RONetwork",
            dependencies: [
                "ROCore",
            ]),
        .testTarget(
            name: "RONetworkTests",
            dependencies: [
                "RONetwork",
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
                .product(name: "Lua", package: "swift-lua"),
                "ROCore",
                "ROFileFormats",
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
