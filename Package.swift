// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "MicroContainer",
            dependencies: [],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "MicroContainerTests",
            dependencies: ["MicroContainer"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        )
    ]
)
