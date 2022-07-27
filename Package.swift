// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "JudoSDKFileLoader",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "JudoSDKFileLoader",
            targets: ["JudoSDKFileLoaderModel", "JudoSDKFileLoader"]),
    ],
    dependencies: [
        .package(url: "https://github.com/judoapp/judo-ios.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "JudoSDKFileLoaderModel",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .target(
            name: "JudoSDKFileLoader",
            dependencies: [
                "JudoSDKFileLoaderModel",
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "JudoSDK", package: "judo-ios")
            ]
        )
    ]
)


