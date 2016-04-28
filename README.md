#BluemixHTTPSClient

[![Swift][swift-badge]][swift-url]
[![Platform][platform-badge]][platform-url]

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg
[platform-url]: https://swift.org

## Installation
```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-httpsclient-swift.git", majorVersion: 0)
    ]
)

BluemixHTTPSClient was tested on OSX and Linux with DEVELOPMENT-SNAPSHOT-2016-04-25-a

```
## Setup

The BluemixHTTPSClient is a simple abstraction layer on top of https://github.com/VeniceX/HTTPSClient.git, which uses several C libraries. There's a basic one time setup you'll need to perform in order to get these C libraries on your machine.

#### Build on Linux

```bash
sudo apt-get update
sudo apt-get install libssl-dev
swift build
```

### Build in Docker:

In general, building on Docker is similar to building on Linux. However since Docker container by default runs as root user you will need to copy the openssl folder from `/usr/include` to `/usr/local/include`

```bash
cp -avr /usr/include/openssl /usr/local/include/openssl
```

Alternatively you can specify these folders when using `swift build` via -Xcc and -Xlinker flags.

### Build on Mac:

```bash
brew install openssl
brew link --force openssl
swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib -X
export LD_LIBRARY_PATH=$(pwd)/.build/debug
```

Two things to note:

1. Several internal dependencies will produce .so files that will be stored in the `.build/debug` folder once build is complete. Setting the `LD_LIBRARY_PATH` environment variable will ensure those .so files can be found.
2. The last -X flag in the build command will generate/update Xcode project you can use for development. You might want to omit it since it may override existing Xcode project you've previously created. In case you want to manually configure Xcode project to use C libraries add below values to the OpenSSL target Build Settings

> Add `/usr/local/include` to User Header Search Paths
>
> Add `-L/usr/local/lib` to Other Linker Flags

## Using on Bluemix

TBD

## Usage

```swift
let headers = ["Content-Type":"application/json"];
let data = NSData()

HTTPSClient.get(url: "http://example.com", headers: headers) { (error, data, status, headers) in
	if error != nil {
		print("error :: \(error)")
	} else {
		print("success :: \(data)")
	}
}

HTTPSClient.delete(url: "http://example.com", headers: headers) { (error, data, status, headers) in
	if error != nil {
		print("error :: \(error)")
	} else {
		print("success :: \(data)")
	}
}


HTTPSClient.head(url: "http://example.com", headers: headers) { (error, data, status, headers) in
	if error != nil {
		print("error :: \(error)")
	} else {
		print("success :: \(data)")
	}
}

HTTPSClient.post(url: "http://example.com", headers: headers, data: data) { (error, data, status, headers) in
	if error != nil {
		print("error :: \(error)")
	} else {
		print("success :: \(data)")
	}
}

HTTPSClient.put(url: "http://example.com", headers: headers, data: data) { (error, data, status, headers) in
	if error != nil {
		print("error :: \(error)")
	} else {
		print("success :: \(data)")
	}
}
```

## License

This project is released under the Apache-2.0 license

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg
[platform-url]: https://swift.org
