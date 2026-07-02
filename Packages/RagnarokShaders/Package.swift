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
                .process("Effect/Effect3DShaders.metal"),
                .process("Effect/CylinderEffectShaders.metal"),
                .process("Effect/SPREffectShaders.metal"),
                .process("Effect/STREffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Skybox/SkyboxShaders.metal"),
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
