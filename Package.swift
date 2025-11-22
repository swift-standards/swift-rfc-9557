// swift-tools-version: 6.2

import PackageDescription

// RFC 9557: Date and Time on the Internet: Timestamps with Additional Information
//
// Implements RFC 9557 Internet Extended Date/Time Format (IXDTF).
// RFC 9557 extends RFC 3339 with optional suffix information:
// - Time zone identifiers (IANA Time Zone Database)
// - Calendar system preferences (Unicode TR35)
// - Critical/elective flag mechanism
// - Custom suffix tags
//
// This implementation builds on swift-rfc-3339 for the base timestamp format.

let package = Package(
    name: "swift-rfc-9557",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "RFC 9557",
            targets: ["RFC 9557"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.1.0"),
        .package(path: "../swift-rfc-3339")
    ],
    targets: [
        .target(
            name: "RFC 9557",
            dependencies: [
                .product(name: "Standards", package: "swift-standards"),
                .product(name: "StandardTime", package: "swift-standards"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "RFC 3339", package: "swift-rfc-3339")
            ]
        ),
        .testTarget(
            name: "RFC 9557".tests,
            dependencies: [
                "RFC 9557",
                .product(name: "StandardsTestSupport", package: "swift-standards")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
