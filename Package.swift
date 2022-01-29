// swift-tools-version:5.3.0

import PackageDescription

let package = Package(
    name: "CoreRIB",
    platforms: [
        .iOS("15")
    ],
    products: [
        .library(
            name: "RoutingQueue",
            targets: [
                "RoutingQueue"
            ]
        ),
        .library(
            name: "CoreRIB",
            targets: [
                "CoreRIB"
            ]
        ),
        .library(
            name: "RouterIdentifier",
            targets: [
                "RouterIdentifier"
            ]
        )
    ],
    dependencies: [
        .package(name: "Core", url: "https://github.com/kutchie-pelaez-packages/Core.git", .branch("master")),
        .package(name: "CoreUI", url: "https://github.com/kutchie-pelaez-packages/CoreUI.git", .branch("master")),
        .package(name: "SheetTransition", url: "https://github.com/kutchie-pelaez-packages/SheetTransition.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "RoutingQueue",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .target(name: "CoreRIB"),
                .target(name: "RouterIdentifier")
            ]
        ),
        .target(
            name: "CoreRIB",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "CoreUI", package: "CoreUI"),
                .product(name: "SheetTransition", package: "SheetTransition"),
                .target(name: "RouterIdentifier")
            ]
        ),
        .target(name: "RouterIdentifier")
    ]
)
