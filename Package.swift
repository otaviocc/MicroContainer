// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MicroContainer",
    products: [
        .library(
            name: "MicroContainer",
            targets: ["MicroContainer"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MicroContainer",
            dependencies: []),
        .testTarget(
            name: "MicroContainerTests",
            dependencies: ["MicroContainer"]
        )
    ]
)
