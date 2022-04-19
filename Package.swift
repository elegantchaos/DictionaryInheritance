// swift-tools-version:5.5

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "DictionaryResolver",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(
            name: "DictionaryResolver",
            targets: ["DictionaryResolver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.9"),
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.4.2")
    ],
    targets: [
        .target(
            name: "DictionaryResolver",
            dependencies: ["CollectionExtensions"]
        ),
        
        .testTarget(
            name: "DictionaryResolverTests",
            
            dependencies: ["DictionaryResolver", "XCTestExtensions"],
            
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
