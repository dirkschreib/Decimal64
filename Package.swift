// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Decimals",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "Decimals", targets: ["Decimals"]),
        .executable(name: "DecimalsBenchmarks", targets: ["DecimalsBenchmarks"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Decimals", dependencies: [], path: "sources"),
        .testTarget(name: "DecimalsTests", dependencies: ["Decimals"], path: "tests"),
        .target(name: "DecimalsBenchmarks", dependencies: ["Decimals"], path: "benchmarks")
    ]
)
