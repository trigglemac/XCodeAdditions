// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCodeAdditions",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "XCodeAdditions",
            targets: ["XCodeAdditions"]),
    ],
    targets: [
        .target(
            name: "XCodeAdditions"),
        .testTarget(
            name: "XCodeAdditionsTests",
            dependencies: ["XCodeAdditions"]
        ),
    ]
)
