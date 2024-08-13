// swift-tools-version: 5.10
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
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
        .package(path: "swift-lua"),
        .package(path: "swift-rathena"),
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
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROCore",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
            ]),
        .target(
            name: "RODatabase",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
                .product(name: "ryml", package: "swift-rathena"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROFileFormats",
            dependencies: [
                "DataCompression",
                "ROCore",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
            ]),
        .target(
            name: "ROFileSystem",
            dependencies: [
                "ROCore",
                "ROFileFormats",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
            ]),
        .target(
            name: "RONetwork",
            dependencies: [
                .product(name: "rAthenaCommon", package: "swift-rathena"),
                "ROResources",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "RORenderers",
            dependencies: [
                "ROCore",
                "ROFileFormats",
                "ROShaders",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
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
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .interoperabilityMode(.Cxx),
            ]),
        .target(
            name: "ROShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
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
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
            ]),
        .testTarget(
            name: "RONetworkTests",
            dependencies: [
                .product(name: "rAthenaResources", package: "swift-rathena"),
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                "RONetwork",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .interoperabilityMode(.Cxx),
            ]),
        .testTarget(
            name: "ROResourcesTests",
            dependencies: [
                "ROResources",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .interoperabilityMode(.Cxx),
            ]),
    ]
)
