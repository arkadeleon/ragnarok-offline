// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokRenderers",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokRenderers",
            targets: ["RagnarokRenderers"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../SGLMath"),
    ],
    targets: [
        .target(
            name: "RagnarokRenderers",
            dependencies: [
                "RagnarokFileFormats",
                "RagnarokShaders",
                "SGLMath",
            ]
        ),
        .target(
            name: "RagnarokShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]
        ),
        .testTarget(
            name: "RagnarokRenderersTests",
            dependencies: ["RagnarokRenderers"]
        ),
        .testTarget(
            name: "RagnarokShadersTests",
            dependencies: ["RagnarokShaders"]
        ),
    ]
)
