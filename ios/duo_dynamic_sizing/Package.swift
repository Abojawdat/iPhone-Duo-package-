// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "duo_dynamic_sizing",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "duo-dynamic-sizing", targets: ["duo_dynamic_sizing"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "duo_dynamic_sizing",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
