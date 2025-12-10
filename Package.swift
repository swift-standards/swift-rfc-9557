// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-rfc-9557",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "RFC 9557", targets: ["RFC 9557"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.3.0"),
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-3339", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "RFC 9557",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "Standards", package: "swift-standards"),
                .product(name: "RFC 3339", package: "swift-rfc-3339"),
            ]
        ),
        .testTarget(
            name: "RFC 9557".tests,
            dependencies: ["RFC 9557"]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
