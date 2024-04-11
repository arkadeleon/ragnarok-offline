// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ragnarok-offline",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "ROCrypto",
            targets: ["ROCrypto"]),
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
            name: "ROSettings",
            targets: ["ROSettings"]),
        .library(
            name: "ROShaders",
            targets: ["ROShaders"]),
        .library(
            name: "ROStream",
            targets: ["ROStream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
        .package(path: "swift-rathena"),
    ],
    targets: [
        .target(
            name: "ROCrypto"),
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
            ],
            exclude: [
                "Entity/Entity.swift",
            ]),
        .target(
            name: "ROSettings"),
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
            name: "ROFileFormatsTests",
            dependencies: ["ROFileFormats"]),
    ]
)
