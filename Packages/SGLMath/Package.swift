// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SGLMath",
    products: [
        .library(
            name: "SGLMath",
            targets: ["SGLMath"]
        ),
    ],
    targets: [
        .target(
            name: "SGLMath"
        ),
        .testTarget(
            name: "SGLMathTests",
            dependencies: ["SGLMath"]
        ),
    ]
)
