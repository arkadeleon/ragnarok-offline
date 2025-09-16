// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ro",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RODatabase",
            targets: ["RODatabase"]),
        .library(
            name: "ROGame",
            targets: ["ROGame"]),
        .library(
            name: "RORendering",
            targets: ["RORendering"]),
    ],
    dependencies: [
        .package(path: "../BinaryIO"),
        .package(path: "../Constants"),
        .package(path: "../FileFormats"),
        .package(path: "../ImageRendering"),
        .package(path: "../MetalRenderers"),
        .package(path: "../NetworkClient"),
        .package(path: "../PerformanceMetric"),
        .package(path: "../ResourceManagement"),
        .package(path: "../SGLMath"),
        .package(path: "../TextEncoding"),
        .package(url: "https://github.com/arkadeleon/swift-gzip.git", branch: "main"),
        .package(url: "https://github.com/arkadeleon/swift-rapidyaml.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RODatabase",
            dependencies: [
                "BinaryIO",
                "Constants",
                "PerformanceMetric",
                .product(name: "SwiftGzip", package: "swift-gzip"),
                .product(name: "RapidYAML", package: "swift-rapidyaml"),
            ]),
        .testTarget(
            name: "RODatabaseTests",
            dependencies: [
                "RODatabase",
            ]),
        .target(
            name: "ROGame",
            dependencies: [
                "Constants",
                "FileFormats",
                "ImageRendering",
                "MetalRenderers",
                "NetworkClient",
                "PerformanceMetric",
                "RORendering",
                "ResourceManagement",
                "SGLMath",
                "TextEncoding",
            ]),
        .target(
            name: "RORendering",
            dependencies: [
                "Constants",
                "FileFormats",
                "ResourceManagement",
                "TextEncoding",
            ]),
        .testTarget(
            name: "RORenderingTests",
            dependencies: [
                "RORendering",
            ]),
    ]
)
