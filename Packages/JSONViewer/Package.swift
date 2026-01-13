// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSONViewer",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "JSONViewer",
            targets: ["JSONViewer"]
        ),
    ],
    targets: [
        .target(
            name: "JSONViewer"
        ),
        .testTarget(
            name: "JSONViewerTests",
            dependencies: ["JSONViewer"]
        ),
    ]
)
