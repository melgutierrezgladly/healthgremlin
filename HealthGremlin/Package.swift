// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift needed to build this package.

import PackageDescription

let package = Package(
    name: "HealthGremlin",
    // macOS 14 (Sonoma) minimum — required for our SwiftUI features
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "HealthGremlin",
            path: "HealthGremlin",
            exclude: ["Info.plist"],
            resources: [
                // This tells SPM to include our asset catalog in the app bundle
                .process("Resources")
            ]
        )
    ]
)
