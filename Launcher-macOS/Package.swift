// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ReSkateLauncher",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "reskate-launcher", targets: ["ReSkateLauncher"]),
    ],
    targets: [
        .executableTarget(
            name: "ReSkateLauncher",
            path: "Sources",
            exclude: [],
            sources: ["App", "Models", "Services", "Views"],
            resources: [
                .process("../Resources"),
            ]
        ),
        .testTarget(
            name: "ReSkateLauncherTests",
            dependencies: ["ReSkateLauncher"],
            path: "Tests"
        ),
    ]
)
