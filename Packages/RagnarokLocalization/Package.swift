// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RagnarokLocalization",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "RagnarokLocalization",
            targets: ["RagnarokLocalization"]
        ),
    ],
    targets: [
        .target(
            name: "RagnarokLocalization",
            exclude: [
                "Resources/zh-Hans.lproj/ScriptText.json",
                "Resources/zh-Hant.lproj/ScriptText.json",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "RagnarokLocalizationTests",
            dependencies: ["RagnarokLocalization"]
        ),
    ]
)
