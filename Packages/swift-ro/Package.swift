// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ro",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ROClient",
            targets: ["ROClient"]),
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
            name: "ROFileSystem",
            targets: ["ROFileSystem"]),
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
            name: "ROShaders",
            targets: ["ROShaders"]),
    ],
    dependencies: [
        .package(path: "../swift-lua"),
        .package(path: "../swift-rathena"),
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
    ],
    targets: [
        .target(
            name: "ROClient",
            dependencies: [
                "ROCore",
                "RODatabase",
                "ROFileFormats",
                "ROFileSystem",
                "ROResources",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .swiftLanguageMode(.v5),
            ]),
        .target(
            name: "ROCore"),
        .target(
            name: "RODatabase",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                .product(name: "ryml", package: "swift-rathena"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROFileFormats",
            dependencies: [
                "DataCompression",
                "ROCore",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]),
        .target(
            name: "ROFileSystem",
            dependencies: [
                "ROCore",
                "ROFileFormats",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]),
        .target(
            name: "ROGame",
            dependencies: [
                "RONetwork",
                "ROResources",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]),
        .target(
            name: "ROGenerated"),
        .target(
            name: "RONetwork",
            dependencies: [
                "ROGenerated",
                "ROResources",
            ],
            swiftSettings: [
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
                .process("Images"),
                .process("Resources"),
            ]),
        .target(
            name: "ROShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]),
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
            name: "RONetworkTests",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                "RONetwork",
            ]),
        .testTarget(
            name: "ROResourcesTests",
            dependencies: [
                "ROResources",
            ]),
        .plugin(
            name: "ROGenerator",
            capability: .command(
                intent: .custom(verb: "generate", description: ""),
                permissions: [
                    .writeToPackageDirectory(reason: ""),
                ]
            )),
    ]
)
