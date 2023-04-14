// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CachePropertyKit",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CachePropertyKit",
            targets: ["CachePropertyKit"]
        ),
    ],
    targets: [
        .target(
            name: "CachePropertyKit",
            path: "Sources"
        ),
        .testTarget(
            name: "CachePropertyKitTests",
            dependencies: ["CachePropertyKit"],
            path: "Tests"
        ),
    ]
)
