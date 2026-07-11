// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacBuddy",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MacBuddy", targets: ["MacBuddy"]),
        .library(name: "MacBuddyCore", targets: ["MacBuddyCore"])
    ],
    targets: [
        .target(name: "MacBuddyCore"),
        .executableTarget(
            name: "MacBuddy",
            dependencies: ["MacBuddyCore"]
        ),
        .executableTarget(
            name: "MacBuddySelfTests",
            dependencies: ["MacBuddyCore"]
        )
    ]
)
