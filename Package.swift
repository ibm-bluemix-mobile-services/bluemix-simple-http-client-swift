import PackageDescription

let package = Package(
    name: "BluemixHTTPSClient",
	dependencies:[
		.Package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-simplelogger.git", majorVersion: 0),
		.Package(url: "https://github.com/VeniceX/HTTPSClient.git", majorVersion: 0, minor: 5),
	]
)
