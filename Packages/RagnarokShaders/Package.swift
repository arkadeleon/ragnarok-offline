// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokShaders",
    products: [
        .library(
            name: "RagnarokShaders",
            targets: ["RagnarokShaders"]
        ),
    ],
    targets: [
        .target(
            name: "RagnarokShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Sprite/SpriteShaders.metal"),
                .process("Tile/TileShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]
        ),
        .testTarget(
            name: "RagnarokShadersTests",
            dependencies: ["RagnarokShaders"]
        ),
    ]
)
