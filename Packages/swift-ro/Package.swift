// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ro",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .visionOS(.v1),
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
            name: "ROCore"),
        .target(
            name: "RODatabase",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                .product(name: "ryml", package: "swift-rathena"),
                "DataCompression",
                "ROGenerated",
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
                .product(name: "Lua", package: "swift-lua"),
                "ROCore",
                "ROFileFormats",
                "ROGenerated",
                "RORenderers",
                "ROResources",
            ]),
        .target(
            name: "ROGenerated",
            dependencies: [
                "ROCore",
            ]),
        .target(
            name: "RONetwork",
            dependencies: [
                "ROCore",
                "ROGenerated",
                "ROResources",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]),
        .testTarget(
            name: "RONetworkTests",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                "RODatabase",
                "RONetwork",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .swiftLanguageMode(.v5),
            ]),
        .target(
            name: "RORenderers",
            dependencies: [
                "ROCore",
                "ROFileFormats",
                "ROShaders",
            ]),
        .target(
            name: "ROResources",
            dependencies: [
                .product(name: "Lua", package: "swift-lua"),
                "ROCore",
            ],
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "ROResourcesTests",
            dependencies: [
                "ROGenerated",
                "ROResources",
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
