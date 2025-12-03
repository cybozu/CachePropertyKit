// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CachePropertyKit",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CachePropertyKit",
            targets: ["CachePropertyKit"]
        ),
    ],
    targets: [
        .target(
            name: "CachePropertyKit"
        ),
        .testTarget(
            name: "CachePropertyKitTests",
            dependencies: ["CachePropertyKit"]
        ),
    ]
)
