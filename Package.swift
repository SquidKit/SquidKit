// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SquidKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "SquidKit", targets: ["SquidKit"])
    ],
    targets: [
        .target(name: "SquidKit", path: "SquidKit")
    ]
)
