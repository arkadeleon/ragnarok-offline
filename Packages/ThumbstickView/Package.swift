// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The package that contains a UI for thumbstick control.
*/

import PackageDescription

let package = Package(
    name: "ThumbstickView",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ThumbstickView",
            targets: ["ThumbstickView"]
        ),
    ],
    targets: [
        .target(
            name: "ThumbstickView",
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility"),
            ]
        ),
    ]
)
