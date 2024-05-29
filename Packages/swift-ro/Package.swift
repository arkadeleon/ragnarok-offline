// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ro",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "ROClient",
            targets: ["ROClient"]),
        .library(
            name: "ROCrypto",
            targets: ["ROCrypto"]),
        .library(
            name: "RODatabase",
            targets: ["RODatabase"]),
        .library(
            name: "ROFileFormats",
            targets: ["ROFileFormats"]),
        .library(
            name: "ROFileSystem",
            targets: ["ROFileSystem"]),
        .library(
            name: "ROGraphics",
            targets: ["ROGraphics"]),
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
            name: "ROShaders",
            targets: ["ROShaders"]),
        .library(
            name: "ROStream",
            targets: ["ROStream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
        .package(path: "swift-lua"),
        .package(path: "swift-rathena"),
    ],
    targets: [
        .target(
            name: "ROClient",
            dependencies: [
                "RODatabase",
                "ROFileFormats",
                "ROFileSystem",
                "ROGraphics",
                "ROResources",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROCrypto"),
        .target(
            name: "RODatabase",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaResource", package: "swift-rathena"),
                .product(name: "rAthenaRyml", package: "swift-rathena"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROFileFormats",
            dependencies: [
                "DataCompression",
                "ROCrypto",
                "ROStream",
            ]),
        .target(
            name: "ROFileSystem",
            dependencies: [
                "ROFileFormats",
                "ROGraphics",
            ]),
        .target(
            name: "ROGraphics",
            dependencies: [
                "ROFileFormats",
            ]),
        .target(
            name: "RONetwork",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
            ]),
        .target(
            name: "RORenderers",
            dependencies: [
                "ROGraphics",
                "ROShaders",
            ]),
        .target(
            name: "ROResources",
            dependencies: [
                .product(name: "Lua", package: "swift-lua"),
                "RODatabase",
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]),
        .target(
            name: "ROStream"),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .testTarget(
            name: "ROFileFormatsTests",
            dependencies: [
                "ROFileFormats"
            ],
            resources: [
                .copy("test.grf"),
                .copy("data"),
            ]),
        .testTarget(
            name: "ROResourcesTests",
            dependencies: [
                "ROResources",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
    ]
)
