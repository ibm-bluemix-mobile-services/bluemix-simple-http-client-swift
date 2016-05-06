import XCTest
import Foundation
@testable import SimpleHttpClient

class HttpClientTests: XCTestCase {
	let httpResource = HttpResourse(schema: "http", host: "httpbin.org", port: "80")
	let httpsResource = HttpResourse(schema: "https", host: "httpbin.org", port: "443")
	let testString = "TestDataSimpleHttpClient"
	var testData:NSData!
	
	override func setUp() {
		#if os(Linux)
			testData = testString.dataUsingEncoding(NSUTF8StringEncoding)
		#else
			testData = testString.data(using: NSUTF8StringEncoding)
		#endif
	}

	func testHttpResourceInitializer(){
		let resource = HttpResourse(schema: "schema", host: "host", port: "port", path: "path")
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
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/get")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(data, "data == nil")
		}
	}

	func testPost(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/post")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.post(resource: resource, headers: headers, data: testData) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(data, "data == nil")
			let responseString = String(data: data!, encoding:NSUTF8StringEncoding)
			#if os(Linux)
				XCTAssertTrue(responseString!.containsString("TestDataSimpleHttpClient"))
			#else
				XCTAssertTrue(responseString!.contains("TestDataSimpleHttpClient"))
			#endif
		}
	}

	func testHead(){
		HttpClient.head(resource: httpResource) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
		}
	}

	func testPut(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/put")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.put(resource: resource, headers: headers, data: testData) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
			XCTAssertNotNil(data, "data == nil")
			let responseString = String(data: data!, encoding:NSUTF8StringEncoding)
			#if os(Linux)
				XCTAssertTrue(responseString!.containsString("TestDataSimpleHttpClient"))
			#else
				XCTAssertTrue(responseString!.contains("TestDataSimpleHttpClient"))
			#endif
		}
	}

	func testDelete(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/delete")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.delete(resource: resource, headers: headers) { error, status, headers, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertTrue(status == 200, "status != 200")
			XCTAssertNotNil(headers, "headers == nil")
		}
	}

	func testNotFound(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/afasdfasdfasdf")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertNotNil(error, "error == nil")
			XCTAssertEqual(error?.rawValue, HttpError.NotFound.rawValue, "error.rawValue != HttpError.NotFound.rawValue")
			XCTAssertTrue(status == 404, "status != 404")
		}
	}

	func testUnauthorized(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/basic-auth/user/passwd")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertNotNil(error, "error == nil")
			XCTAssertEqual(error?.rawValue, HttpError.Unauthorized.rawValue, "error.rawValue != HttpError.Unauthorized.rawValue")
			XCTAssertTrue(status == 401, "status != 401")
		}
	}
}
extension HttpClientTests {
	static var allTests : [(String, HttpClientTests -> () throws -> Void)] {
		return [
		       	("testGet", testGet),
		       	("testDelete", testDelete),
		       	("testHead", testHead),
		       	("testPost", testPost),
		       	("testPut", testPut),
		       	("testHttpResourceInitializer",testHttpResourceInitializer),
		       	("testHttpResourceByAddingPathComponent",testHttpResourceByAddingPathComponent),
		       	("testNotFound", testNotFound),
		       	("testUnauthorized", testUnauthorized)
		]
	}
}