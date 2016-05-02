import Foundation
import BluemixSimpleLogger
import KituraNet

/// An alias for a network request completion handler, receives back error, status, headers and data
public typealias NetworkRequestCompletionHandler = (error:HttpError?, status:Int?, headers: [String:String]?, data:NSData?) -> Void

internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

/// Used for specifying an Http Resource that the request will be made to
public struct HttpResourse{
	
	/// Request schema, should be either http or https
	let schema:String
	
	/// Resource host name, e.g. www.example.com
	let host:String
	
	/// Resource port, e.g. 80
	let port:String
	
	/// Resource path, e.g. /my/resource/id/123
	let path:String
	
	/// Use this initializer at your own risk, it has a very simplistic implementation and assumes your URI is valid
	/// in form of http[s]://hostname[:port]/[path]
	public init(uri: String){
		#if os(Linux)
			let uriComponents = uri.componentsSeparatedByString("/")
		#else
			let uriComponents = uri.components(separatedBy: "/")
		#endif
		self.schema = uriComponents[0]
		let hostname = uriComponents[2]
		#if os(Linux)
			let hostnameComponents = hostname.componentsSeparatedByString(":")
		#else
			let hostnameComponents = hostname.components(separatedBy: ":")
		#endif
		if hostnameComponents.count > 1{
			self.host = hostnameComponents[0]
			self.port = hostnameComponents[1]
		} else {
			self.host = hostname
			self.port = self.schema == "https" ? "443":"80"
		}
		
		self.path = uriComponents[3]
	}

	/**
	Initialize the HttpResource by specifying all properties
	
	- Parameter schema: Request schema, should be either http or https
	- Parameter host: Resource host name, e.g. www.example.com
	- Parameter port: Resource port, e.g. 80
	- Parameter path: Resource path, e.g. /my/resource/id/123
	*/
	
	public init(schema:String, host: String, port: String, path: String = "") {
		self.schema = schema
		self.host = host
		self.port = port
		self.path = path
	}
	
	/**
	Create a new HttpResource by adding components to path

	- Parameter pathComponent: components to add
	*/
	public func resourceByAddingPathComponent(pathComponent:String) -> HttpResourse {
		return HttpResourse(schema: self.schema, host: self.host, port: self.host, path: self.path + pathComponent)
	}
}

/// Use HttpClient to make Http requests
public class HttpClient{
	
	public static let logger = Logger(forName: "HttpClient")

	/**
	Send a GET request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func get(resource: HttpResourse, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "GET" , headers: headers, completionHandler: completionHandler)
	}

	/**
	Send a PUT request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func put(resource: HttpResourse, headers:[String:String]? = nil, data:NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "PUT" , headers: headers, data: data, completionHandler: completionHandler)
	}

	/**
	Send a DELETE request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func delete(resource: HttpResourse, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "DELETE" , headers: headers, completionHandler: completionHandler)
	}

	/**
	Send a POST request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func post(resource: HttpResourse, headers:[String:String]? = nil, data:NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "POST" , headers: headers, data: data, completionHandler: completionHandler)
	}

	/**
	Send a HEAD request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func head(resource: HttpResourse, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
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
	private class func sendRequest(to resource: HttpResourse, method:String, headers:[String:String]? = nil, data: NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		
		var requestOptions = Array<ClientRequestOptions>()
		requestOptions.append(.Method(method))
		requestOptions.append(.Schema(resource.schema + "://"))
		requestOptions.append(.Hostname(resource.host))
		requestOptions.append(.Path(resource.path))

		let request = Http.request(requestOptions) { (response) in
			handleResponse(response: response, completionHandler: completionHandler)
		}
		
		if let headers = headers {
			for (name, value) in headers{
				request.headers[name] = value
			}
		}

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
				headers.updateValue(header.1, forKey: header.0)
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
