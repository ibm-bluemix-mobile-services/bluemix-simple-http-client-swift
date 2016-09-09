import XCTest
import Foundation
@testable import SimpleHttpClient

class HttpClientTests: XCTestCase {
	let httpResource = HttpResource(schema: "http", host: "httpbin.org", port: "80")
	let httpsResource = HttpResource(schema: "https", host: "httpbin.org", port: "443")
	let testString = "TestDataSimpleHttpClient"
	var testData:Data!
	let expectationTimeout = 30.0

	override func setUp() {
		self.continueAfterFailure = false
		testData = testString.data(using: String.Encoding.utf8)
	}

	func testHttpResourceInitializer(){
		let resource = HttpResource(schema: "schema", host: "host", port: "port", path: "path")
		XCTAssertEqual(resource.host, "host", "resource.host != host")
		XCTAssertEqual(resource.schema, "schema", "resource.schema != schema")
		XCTAssertEqual(resource.port, "port", "resource.port != port")
		XCTAssertEqual(resource.path, "path", "resource.path != path")
	}

	func testHttpResourceByAddingPathComponent(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/component")
		XCTAssertEqual(resource.schema, "https", "resource.schema != https")
		XCTAssertEqual(resource.host, "httpbin.org", "resource.host != httpbin.org")
		XCTAssertEqual(resource.port, "443", "resource.port != 443")
		XCTAssertEqual(resource.path, "/component", "resource.path != /component")
	}

	func testHttpResourceFullUri(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/a?e=f&g=h")
		XCTAssertEqual(resource.uri, "https://httpbin.org:443/a?e=f&g=h", "resource.uri != https://httpbin.org:443/a?e=f&g=h")
	}

	func testGet(){
		let exp = expectation(description: "exp")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/get")

		HttpClient.get(resource: resource) { error, status, headers, data in
			print("Status \(status)")
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(data, "data == nil")
			exp.fulfill()
		}

		waitForExpectations(timeout: expectationTimeout, handler: nil)
	}

	func testPost(){
		let exp = expectation(description: "expectation")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/post")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.post(resource: resource, headers: headers, data: testData) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(data, "data == nil")
			let responseString = String(data: data!, encoding:String.Encoding.utf8)
			XCTAssertTrue(responseString!.contains(self.testString))
			exp.fulfill()
		}
		waitForExpectations(timeout: expectationTimeout, handler: nil)

	}

	func testPut(){
		let exp = expectation(description: "expectation")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/put")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.put(resource: resource, headers: headers, data: testData) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(data, "data == nil")
			let responseString = String(data: data!, encoding:String.Encoding.utf8)
			XCTAssertTrue(responseString!.contains(self.testString))
			exp.fulfill()
		}
		waitForExpectations(timeout: expectationTimeout, handler: nil)

	}

	func testDelete(){
		let exp = expectation(description: "expectation")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/delete")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.delete(resource: resource, headers: headers) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			exp.fulfill()
		}
		waitForExpectations(timeout: expectationTimeout, handler: nil)

	}

	func testNotFound(){
		let exp = expectation(description: "expectation")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/afasdfasdfasdf")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertNotNil(error, "error == nil")
			XCTAssertEqual(error?.rawValue, HttpError.NotFound.rawValue, "error.rawValue != HttpError.NotFound.rawValue")
			XCTAssertTrue(status == 404, "status != 404")
			exp.fulfill()
		}
		waitForExpectations(timeout: expectationTimeout, handler: nil)

	}

	func testUnauthorized(){
		let exp = expectation(description: "expectation")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/basic-auth/user/passwd")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertNotNil(error, "error == nil")
			XCTAssertEqual(error?.rawValue, HttpError.Unauthorized.rawValue, "error.rawValue != HttpError.Unauthorized.rawValue")
			XCTAssertTrue(status == 401, "status != 401")
			exp.fulfill()
		}
		waitForExpectations(timeout: expectationTimeout, handler: nil)

	}

	func testResponseHeaders(){
		let exp = expectation(description: "expectation")

		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/headers")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(headers!["Content-Type"], "headers[Content-Type] == nil")
			exp.fulfill()
		}
		waitForExpectations(timeout: expectationTimeout, handler: nil)

	}
}

extension HttpClientTests {
	static var allTests : [(String, (HttpClientTests) -> () throws -> Void)] {
		return [
			("testHttpResourceInitializer",testHttpResourceInitializer),
			("testHttpResourceByAddingPathComponent",testHttpResourceByAddingPathComponent),
			("testHttpResourceFullUri",testHttpResourceFullUri),
			("testGet", testGet),
			("testPost", testPost),
			("testPut", testPut),
			("testDelete", testDelete),
//			("testNotFound", testNotFound),
//			("testUnauthorized", testUnauthorized),
			("testResponseHeaders", testResponseHeaders)
		]
	}
}
