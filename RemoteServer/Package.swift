// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteServer",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: "../swift-rathena"),
    ],
    targets: [
        .executableTarget(
            name: "RemoteServer",
            dependencies: [
                .product(name: "rAthenaLogin", package: "swift-rathena"),
                .product(name: "rAthenaChar", package: "swift-rathena"),
                .product(name: "rAthenaMap", package: "swift-rathena"),
                .product(name: "rAthenaWeb", package: "swift-rathena"),
                .product(name: "rAthenaResources", package: "swift-rathena"),
            ]),
    ]
)
