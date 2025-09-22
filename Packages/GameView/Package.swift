// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameView",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "GameView",
            targets: ["GameView"]
        ),
    ],
    dependencies: [
        .package(path: "../GameCore"),
    ],
    targets: [
        .target(
            name: "GameView",
            dependencies: ["GameCore"]
        ),
        .testTarget(
            name: "GameViewTests",
            dependencies: ["GameView"]
        ),
    ]
)
