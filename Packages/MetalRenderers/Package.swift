// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetalRenderers",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "MetalRenderers",
            targets: ["MetalRenderers"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokFileFormats"),
        .package(path: "../SGLMath"),
    ],
    targets: [
        .target(
            name: "MetalRenderers",
            dependencies: [
                "RagnarokFileFormats",
                "MetalShaders",
                "SGLMath",
            ]
        ),
        .target(
            name: "MetalShaders",
            resources: [
                .process("Effect/EffectShaders.metal"),
                .process("Ground/GroundShaders.metal"),
                .process("Model/ModelShaders.metal"),
                .process("Water/WaterShaders.metal"),
            ]
        ),
        .testTarget(
            name: "MetalRenderersTests",
            dependencies: ["MetalRenderers"]
        ),
        .testTarget(
            name: "MetalShadersTests",
            dependencies: ["MetalShaders"]
        ),
    ]
)
