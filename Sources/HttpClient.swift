/*
* Copyright 2016 IBM Corp.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import SimpleLogger
import KituraNet

/// An alias for a network request completion handler, receives back error, status, headers and data
public typealias NetworkRequestCompletionHandler = (error:HttpError?, status:Int?, headers: [String:String]?, data:NSData?) -> Void

internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

/// Use HttpClient to make Http requests
public class HttpClient{
	
	public static let logger = Logger(forName: "HttpClient")

	/**
	Send a GET request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func get(resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "GET" , headers: headers, completionHandler: completionHandler)
	}

	/**
	Send a PUT request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func put(resource: HttpResource, headers:[String:String]? = nil, data:NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "PUT" , headers: headers, data: data, completionHandler: completionHandler)
	}

	/**
	Send a DELETE request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func delete(resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "DELETE" , headers: headers, completionHandler: completionHandler)
	}

	/**
	Send a POST request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func post(resource: HttpResource, headers:[String:String]? = nil, data:NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "POST" , headers: headers, data: data, completionHandler: completionHandler)
	}

	/**
	Send a HEAD request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func head(resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "HEAD" , headers: headers, completionHandler: completionHandler)
	}
}

private extension HttpClient {

	/**
	Send a request

	- Parameter url: The URL to send request to
	- Parameter method: The HTTP method to use
	- Parameter contentType: The value of a 'Content-Type' header
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	private class func sendRequest(to resource: HttpResource, method:String, headers:[String:String]? = nil, data: NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		
		
		var requestOptions = Array<ClientRequest.Options>()
		
		requestOptions.append(.method(method))
		requestOptions.append(.schema(resource.schema + "://"))
		requestOptions.append(.hostname(resource.host))
		requestOptions.append(.path(resource.path))
		
		let request = HTTP.request(requestOptions) { (response) in
			handleResponse(response: response, completionHandler: completionHandler)
		}
		
		if let headers = headers {
			for (name, value) in headers{
				request.headers[name] = value
			}
		}
		
		logger.debug("Sending \(method) request to \(resource.uri)")
			
		if let data = data {
			request.end(data)
		} else {
			request.end()
		}
	}
	
	private class func handleResponse(response: ClientResponse?, completionHandler: NetworkRequestCompletionHandler){
		if let response = response {
			
			// Handle headers
			var headers:[String:String] = [:]
			
			var iterator = response.headers.makeIterator()
			
			while let header = iterator.next(){
				headers.updateValue(header.value[0], forKey: header.key)
			}
			
			// Handle response body
			let responseData = NSMutableData()
			do {
				try response.readAllData(into: responseData)
			} catch {
				return completionHandler(error: HttpError.FailedParsingResponse, status: response.status, headers: headers, data: responseData)
			}

			switch response.status {
			case 401:
				logger.error(String(HttpError.Unauthorized))
				return completionHandler(error: HttpError.Unauthorized, status: response.status, headers: headers, data: responseData)
			case 404:
				logger.error(String(HttpError.NotFound))
				return completionHandler(error: HttpError.NotFound, status: response.status, headers: headers, data: responseData)
			case 400 ... 599:
				logger.error(String(HttpError.ServerError))
				return completionHandler(error: HttpError.ServerError, status: response.status, headers: headers, data: responseData)
			default:
				return completionHandler(error: nil, status: response.status, headers: headers, data: responseData)
			}

		} else {
			completionHandler(error: HttpError.ConnectionFailure, status: nil, headers: nil, data: nil)
		}
	}
}
