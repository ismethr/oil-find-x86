// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "OilFind",
    platforms: [.macOS(.v14)],
    products: [.library(name: "OilFindCore", targets: ["OilFindCore"]), .executable(name: "oilfind-cli", targets: ["oilfind-cli"])],
    targets: [
        .target(name: "COilFind", publicHeadersPath: "include"),
        .target(name: "OilFindCore", dependencies: ["COilFind"]),
        .executableTarget(name: "OilFind", dependencies: ["OilFindCore"]),
        .executableTarget(name: "oilfind-cli", dependencies: ["OilFindCore"]),
        .testTarget(name: "OilFindCoreTests", dependencies: ["OilFindCore", "COilFind"]),
        .testTarget(name: "OilFindUITests", dependencies: ["OilFind", "OilFindCore"])
    ],
    swiftLanguageVersions: [.v5]
)
