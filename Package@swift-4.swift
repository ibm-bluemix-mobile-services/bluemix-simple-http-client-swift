// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

var kituraNetPackage: Package.Dependency

if ProcessInfo.processInfo.environment["KITURA_NIO"] != nil {
    kituraNetPackage = .package(url: "https://github.com/IBM-Swift/Kitura-NIO.git", from: "1.0.0")
} else {
    kituraNetPackage = .package(url: "https://github.com/IBM-Swift/Kitura-net.git", from: "2.1.0")
}

let package = Package(
    name: "SimpleHttpClient",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "SimpleHttpClient", targets: ["SimpleHttpClient"]),
    ],
    dependencies:[
        .package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-simple-logger-swift.git", .upToNextMinor(from: "0.5.0")),
        kituraNetPackage
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target defines a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "SimpleHttpClient", dependencies: ["KituraNet", "SimpleLogger"]),
        .testTarget(name: "SimpleHttpClientTests", dependencies: ["SimpleHttpClient"]),
    ]
)
