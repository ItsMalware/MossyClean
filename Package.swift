// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MossyClean",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MossyClean", targets: ["MossyClean"])
    ],
    targets: [
        .executableTarget(
            name: "MossyClean",
            path: "MossyClean"
        )
    ]
)
