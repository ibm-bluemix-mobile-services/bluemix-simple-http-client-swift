import PackageDescription
import Foundation

var kituraNetPackage: Package.Dependency

if ProcessInfo.processInfo.environment["KITURA_NIO"] != nil {
    kituraNetPackage = .package(url: "https://github.com/IBM-Swift/Kitura-NIO.git", from: "1.0.0")
} else {
    kituraNetPackage = .package(url: "https://github.com/IBM-Swift/Kitura-net.git", majorVersion: 1, minor: 7)
}

let package = Package(
    name: "SimpleHttpClient",
	dependencies:[
		.Package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-simple-logger-swift.git", majorVersion: 0, minor: 5),
		kituraNetPackage
	]
)
