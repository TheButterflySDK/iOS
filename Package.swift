// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TheButterflySDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "TheButterflySDK",
            targets: ["TheButterflySDK"]),
    ],
    targets: [
        .target(
            name: "TheButterflySDK",
            path: "Sources/TheButterflySDK",
            sources: ["objC"],
            resources: [.process("Assets/Resources")],
            publicHeadersPath: "Include",
            cSettings: [ .headerSearchPath("Include") ],
        ),
    ]
)
