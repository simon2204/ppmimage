// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PPMImage",
    products: [
        .library(
            name: "PPMImage",
            targets: ["PPMImage"])
    ],
    targets: [
        .target(
            name: "PPMImage",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PPMImageTests",
            dependencies: ["PPMImage"]),
    ]
)
