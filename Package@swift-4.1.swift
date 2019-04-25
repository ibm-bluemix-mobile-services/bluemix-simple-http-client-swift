// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "SimpleHttpClient",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "SimpleHttpClient", targets: ["SimpleHttpClient"]),
    ],
    dependencies:[
        .package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-simple-logger-swift.git", from: "0.6.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura-net.git", from: "2.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target defines a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "SimpleHttpClient", dependencies: ["KituraNet", "SimpleLogger"]),
        .testTarget(name: "SimpleHttpClientTests", dependencies: ["SimpleHttpClient"]),
    ]
)

