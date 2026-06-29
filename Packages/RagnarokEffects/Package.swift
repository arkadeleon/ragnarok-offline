// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokEffects",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokEffects",
            targets: ["RagnarokEffects"]
        ),
    ],
    dependencies: [
        .package(path: "../RagnarokConstants"),
    ],
    targets: [
        .target(
            name: "RagnarokEffects",
            dependencies: [
                "RagnarokConstants",
            ]
        ),
        .testTarget(
            name: "RagnarokEffectsTests",
            dependencies: ["RagnarokEffects"]
        ),
    ]
)
