// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MicroContainer",
    platforms: [
        .iOS(.v13), .macOS(.v12), .tvOS(.v13), .watchOS(.v6)
    ],
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
            dependencies: []
        ),
        .testTarget(
            name: "MicroContainerTests",
            dependencies: ["MicroContainer"]
        )
    ]
)
