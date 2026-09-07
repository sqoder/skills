// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LiquidGlassKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LiquidGlassKit",
            targets: ["LiquidGlassKit"]
        ),
        .executable(
            name: "LiquidGlassDemo",
            targets: ["LiquidGlassDemo"]
        )
    ],
    targets: [
        .target(
            name: "LiquidGlassKit",
            resources: [
                .process("Shaders")
            ]
        ),
        .executableTarget(
            name: "LiquidGlassDemo",
            dependencies: ["LiquidGlassKit"]
        )
    ]
)
