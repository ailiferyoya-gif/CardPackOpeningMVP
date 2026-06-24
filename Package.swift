// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CardPackOpeningMVP",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "CardPackOpeningMVP", targets: ["CardPackOpeningMVP"])
    ],
    targets: [
        .executableTarget(
            name: "CardPackOpeningMVP",
            path: "Sources/CardPackOpeningMVP"
        )
    ]
)
