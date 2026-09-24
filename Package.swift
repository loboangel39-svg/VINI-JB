// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VINI-JB",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "VINIJB",
            targets: ["VINIJB"]
        )
    ],
    targets: [
        .target(
            name: "VINIJB",
            dependencies: [],
            path: ".",
            exclude: ["Tests", "docs", "README.md", "CONTINUE.md", "Info.plist"],
            sources: [
                "App",
                "FileSystem",
                "Patches",
                "Remote",
                "Models",
                "UI",
                "Authentication",
                "helpers"
            ],
            resources: [
                .process("Info.plist")
            ]
        ),
        .testTarget(
            name: "VINIJBTests",
            dependencies: ["VINIJB"],
            path: "Tests"
        )
    ]
)
