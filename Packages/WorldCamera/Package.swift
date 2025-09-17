// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorldCamera",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "WorldCamera",
            targets: ["WorldCamera"]
        ),
    ],
    targets: [
        .target(
            name: "WorldCamera"
        ),
        .testTarget(
            name: "WorldCameraTests",
            dependencies: ["WorldCamera"]
        ),
    ]
)
