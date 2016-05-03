import XCTest
import Foundation
@testable import SimpleHttpClient

class HttpClientTests: XCTestCase {
	let httpResource = HttpResourse(schema: "http", host: "httpbin.org", port: "80")
	let httpsResource = HttpResourse(schema: "https", host: "httpbin.org", port: "443")
	#if os(Linux)
		let data = "TestDataSimpleHttpClient".dataUsingEncoding(NSUTF8StringEncoding)
	#else
		let data = "TestDataSimpleHttpClient".data(using: NSUTF8StringEncoding)
	#endif


	func testHttpResourceInitializer(){
		let resource = HttpResourse(schema: "schema", host: "host", port: "port", path: "path")
		XCTAssertEqual(resource.host, "host", "host is invalid")
		XCTAssertEqual(resource.schema, "schema", "schema is invalid")
		XCTAssertEqual(resource.port, "port", "port is invalid")
		XCTAssertEqual(resource.path, "path", "path is invalid")
	}

	func testHttpResourceByAddingPathComponent(){
		let res1 = HttpResourse(schema: "schema", host: "host", port: "port", path: "path")
		let res2 = res1.resourceByAddingPathComponent(pathComponent: "/component")
		XCTAssertEqual(res2.path, "path/component", "path is invalid")
	}
	
	func testGet(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/get")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertTrue(status == 200, "Response status is not 200")
			XCTAssertNotNil(headers, "Response headers are nil")
			XCTAssertNotNil(data, "Response data is nil")
		}
	}

	func testPost(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/post")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.post(resource: resource, headers: headers, data: data) { error, status, headers, data in
			XCTAssertTrue(status == 200, "Response status is not 200")
			XCTAssertNotNil(headers, "Response headers are nil")
			XCTAssertNotNil(data, "Response data is nil")
			let responseString = String(data: data!, encoding:NSUTF8StringEncoding)
			#if os(Linux)
				XCTAssertTrue(responseString!.containsString("TestDataSimpleHttpClient"))
			#else
				XCTAssertTrue(responseString!.contains("TestDataSimpleHttpClient"))
			#endif
		}
	}

	func testHead(){
		//		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/head")
		//		HttpClient.head(resource: resource) { error, status, headers, data in
		//			XCTAssertTrue(status == 200, "Response status is not 200")
		//			XCTAssertNotNil(headers, "Response headers are nil")
		//		}
	}

	func testPut(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/put")
		let headers = ["Content-Type":"text/plain"]
		HttpClient.put(resource: resource, headers: headers, data: data) { error, status, headers, data in
			XCTAssertTrue(status == 200, "Response status is not 200")
			XCTAssertNotNil(headers, "Response headers are nil")
			XCTAssertNotNil(data, "Response data is nil")
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
			XCTAssertTrue(status == 200, "Response status is not 200")
			XCTAssertNotNil(headers, "Response headers are nil")
		}
	}

	func testNotFound(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/afasdfasdfasdf")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertTrue(status == 404, "Response status is not 404")
		}
	}

	func testUnauthorized(){
		let resource = httpsResource.resourceByAddingPathComponent(pathComponent: "/basic-auth/user/passwd")
		HttpClient.get(resource: resource) { error, status, headers, data in
			XCTAssertTrue(status == 401, "Response status is not 401")
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
