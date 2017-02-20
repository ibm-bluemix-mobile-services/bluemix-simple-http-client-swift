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
public typealias NetworkRequestCompletionHandler = (_ error:HttpError?, _ status:Int?, _ headers: [String:String]?, _ data:Data?) -> Void

internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

/// Use HttpClient to make Http requests
public class HttpClient{

	public static let logger = Logger(forName: "HttpClient")
	//public static let urlSession = URLSession(configuration: URLSessionConfiguration.default)

	/**
        Send a GET request
     
        - parameter resource: HttpResource instance describing URI schema, host, port and path
        - parameter headers: Dictionary of Http headers to add to request
        - parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func get(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){

		HttpClient.sendRequest(to: resource, method: "GET" , headers: headers, completionHandler: completionHandler)
	}

	/**
        Send a PUT request
     
        - parameter resource: HttpResource instance describing URI schema, host, port and path
        - parameter headers: Dictionary of Http headers to add to request
        - parameter data: The data to send in request body
        - parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func put(resource: HttpResource, headers:[String:String]? = nil, data:Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "PUT" , headers: headers, data: data, completionHandler: completionHandler)
	}

	/**
        Send a DELETE request
     
        - parameter resource: HttpResource instance describing URI schema, host, port and path
        - parameter headers: Dictionary of Http headers to add to request
        - parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func delete(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "DELETE" , headers: headers, completionHandler: completionHandler)
	}

	/**
        Send a POST request
     
        - parameter resource: HttpResource instance describing URI schema, host, port and path
        - parameter headers: Dictionary of Http headers to add to request
        - parameter data: The data to send in request body
        - parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func post(resource: HttpResource, headers:[String:String]? = nil, data:Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "POST" , headers: headers, data: data, completionHandler: completionHandler)
	}

	/**
        Send a HEAD request
     
        - parameter resource: HttpResource instance describing URI schema, host, port and path
        - parameter headers: Dictionary of Http headers to add to request
        - parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func head(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "HEAD" , headers: headers, completionHandler: completionHandler)
	}
    
    /**
         Send a request
     
         - parameter resource: HttpResource instance describing URI schema, host, port and path
         - parameter method: The HTTP method to use
         - parameter headers: Dictionary of Http headers to add to request
         - parameter data: The data to send in request body
         - parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    public class func sendRequest(to resource: HttpResource, method:String, headers:[String:String]? = nil, data: Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        
        
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
}

internal extension HttpClient {
	
	internal class func handleResponse(response: ClientResponse?, completionHandler: NetworkRequestCompletionHandler){
		if let response = response {
			
			// Handle headers
			var headers:[String:String] = [:]
			
			var iterator = response.headers.makeIterator()
			
			while let header = iterator.next(){
				headers.updateValue(header.value[0], forKey: header.key)
			}
			
			// Handle response body
			var responseData = Data()
			do {
				try response.readAllData(into: &responseData)
			} catch {
				return completionHandler(HttpError.FailedParsingResponse, response.status, headers, responseData)
			}
			
			switch response.status {
			case 401:
				logger.error(String(describing: HttpError.Unauthorized))
				return completionHandler(HttpError.Unauthorized, response.status, headers, responseData)
			case 404:
				logger.error(String(describing: HttpError.NotFound))
				return completionHandler(HttpError.NotFound, response.status, headers, responseData)
			case 400 ... 599:
				logger.error(String(describing: HttpError.ServerError))
				return completionHandler(HttpError.ServerError, response.status, headers, responseData)
			default:
				return completionHandler(nil, response.status, headers, responseData)
			}
			
		} else {
			completionHandler(HttpError.ConnectionFailure, nil, nil, nil)
		}
	}
}





// HttpClient implementation using URLSession. Commented out till URLSession is fixed
//internal extension HttpClient {
//
//	/**
//	Send a request
//
//	- Parameter url: The URL to send request to
//	- Parameter method: The HTTP method to use
//	- Parameter contentType: The value of a 'Content-Type' header
//	- Parameter data: The data to send in request body
//	- Parameter completionHandler: NetworkRequestCompletionHandler instance
//	*/
//	internal class func sendRequest(to resource: HttpResource, method:String, headers:[String:String]? = nil, data: Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
//
//		let requestUrl = URL(string: "\(resource.schema)://\(resource.host)\(resource.path)")!
//		var request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
//		request.httpMethod = method;
//
//		if let headers = headers {
//			for (name, value) in headers{
//				request.setValue(value, forHTTPHeaderField: name)
//			}
//		}
//
//		let callback = {(data:Data?, response:URLResponse?, error: Error?) -> Void in
//			if let response = response {
//				let httpResponse:HTTPURLResponse  = response as! HTTPURLResponse
//
//				// Handle headers
//				var headers:[String:String] = [:]
//				for (name, value) in httpResponse.allHeaderFields{
//					#if os(Linux)
//						headers.updateValue(value, forKey: name)
//					#else
//						headers.updateValue(value as! String, forKey: name as! String)
//					#endif
//				}
//
//				switch httpResponse.statusCode {
//				case 401:
//					logger.error(String(describing: HttpError.Unauthorized))
//					return completionHandler(HttpError.Unauthorized, httpResponse.statusCode, headers, data)
//				case 404:
//					logger.error(String(describing: HttpError.NotFound))
//					return completionHandler(HttpError.NotFound, httpResponse.statusCode, headers, data)
//				case 400 ... 599:
//					logger.error(String(describing: HttpError.ServerError))
//					return completionHandler(HttpError.ServerError, httpResponse.statusCode, headers, data)
//				default:
//					return completionHandler(nil, httpResponse.statusCode, headers, data)
//				}
//			} else {
//				completionHandler(HttpError.ConnectionFailure, nil, nil, nil)
//			}
//		}
//
//
//		logger.debug("Sending \(method) request to \(request.url)")
//
//		if let data = data {
//			#if os(Linux)
//				urlSession.uploadTask(with: request, fromData: data, completionHandler: callback).resume()
//			#else
//				urlSession.uploadTask(with: request, from: data, completionHandler: callback).resume()
//			#endif
//		} else {
//			urlSession.dataTask(with: request, completionHandler: callback).resume()
//		}
//	}
//}
