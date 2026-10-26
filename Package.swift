// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "DiskSweep",
    platforms: [.macOS(.v14)],
    targets: [
        // App SwiftUI. Camadas internas: App · Views · ViewModels · Domain · Infrastructure · Support
        .executableTarget(name: "DiskSweep", path: "Sources/DiskSweep"),
        .testTarget(name: "DiskSweepTests", dependencies: ["DiskSweep"], path: "Tests/DiskSweepTests"),
    ]
)
