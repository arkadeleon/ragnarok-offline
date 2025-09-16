// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageRendering",
    products: [
        .library(
            name: "ImageRendering",
            targets: ["ImageRendering"]
        ),
    ],
    targets: [
        .target(
            name: "ImageRendering"
        ),
        .testTarget(
            name: "ImageRenderingTests",
            dependencies: ["ImageRendering"]
        ),
    ]
)
