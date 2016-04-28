import Foundation
import BluemixSimpleLogger
import HTTPSClient

public typealias NetworkRequestCompletionHandler = (error:HttpError?, data:NSData?, status:Int?, headers: [String:String]?) -> Void
internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

class test{
	func a(){
		
	}
}


///	Used to indicate various failure types that might occur during HTTPS operations
public enum HttpError: ErrorProtocol{
	/**
	Indicates a failure during connection attempt. Since response and data is not available in this case an error message might be provided
	
	- Parameter message: An optional description of failure reason
	*/
	case ConnectionFailure(message:String?)

	/// Indicates a resource not being available on server. Returned in case of HTTP 404 status
	case NotFound

	/// Indicates a missing authorization or authentication failure. Returned in case of HTTP 401 status
	case Unauthorized

	/// Indicates an error reported by server. Retruned in cases of HTTP 4xx and 5xx statuses which are not handled separately
	case ServerError
	
	/// Indicates an invalid Uri passed to the BluemixHTTPSClient
	case InvalidUri
	
	/// Indicates that HTTP client was unable to send request
	case InvalidRequest
	
}

public class HTTPSClient{
	public static let logger = Logger(forName: "BluemixHTTPSClient")

	/// Send a GET request
	public class func get(url:String, headers:[String:String]? = nil, completionHandler:NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HTTPSClient.sendRequest(url: url, method: .get , headers: headers, completionHandler: completionHandler)
	}
		
	/// Send a PUT request
	public class func put(url:String, headers:[String:String]? = nil, data:NSData?, completionHandler:NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HTTPSClient.sendRequest(url: url, method: .put , headers: headers, data: data, completionHandler: completionHandler)
	}
		
	/// Send a DELETE request
	public class func delete(url:String, headers:[String:String]? = nil, completionHandler:NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HTTPSClient.sendRequest(url: url, method: .delete , headers: headers, completionHandler: completionHandler)
	}
		
	/// Send a POST request
	public class func post(url:String, headers:[String:String]? = nil, data:NSData?, completionHandler:NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HTTPSClient.sendRequest(url: url, method: .post , headers: headers, data: data, completionHandler: completionHandler)
	}
	
	/// Send a HEAD request
	public class func head(url:String, headers:[String:String]? = nil, completionHandler:NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HTTPSClient.sendRequest(url: url, method: .head , headers: headers, completionHandler: completionHandler)
	}
}

extension HTTPSClient{

	/**
	Send a request
	
	- Parameter url: The URL to send request to
	- Parameter method: The HTTP method to use
	- Parameter contentType: The value of a 'Content-Type' header
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	private class func sendRequest(url:String, method:S4.Method, headers:[String:String]? = nil, data: NSData? = nil, completionHandler:NetworkRequestCompletionHandler){
		var requestUri = try? URI(url)

		guard requestUri != nil else {
			return completionHandler(error: HttpError.InvalidUri, data: nil, status: nil, headers: nil)
		}
		
		if requestUri!.port == nil{
			requestUri!.port = requestUri?.scheme == "https" ? 443 : 80
		}
		
		let client = try? Client(uri:requestUri!)
		guard client != nil else {
			return completionHandler(error: HttpError.InvalidUri, data: nil, status: nil, headers: nil)
		}
		
		var s4headers = S4.Headers()
		
		if let headers = headers {
			for (name, value) in headers{
				var s4header = S4.Header()
				s4header.append(value)
				s4headers.headers.updateValue(s4header, forKey: CaseInsensitiveString(name))
			}
		}
		
		let response:S4.Response?;
		var byteArray:[UInt8] = []
		
		if let data = data {
			let dataLength = data.length
			let bytesCount = dataLength/sizeof(UInt8)
			byteArray = [UInt8](repeating:0, count: bytesCount)
			data.getBytes(&byteArray, length: dataLength)
			response = try? client!.send(method: method, uri: requestUri!.path!, headers: s4headers, body: Data(byteArray))
		} else {
			response = try? client!.send(method: method, uri: requestUri!.path!, headers: s4headers)
		}
		
		
		if var response = response {
			let statusCode = response.status.statusCode
			let s4headers = response.headers
			let responseBodyByteArray = try? response.body.becomeBuffer()
			let responseBodyByteArraySize = responseBodyByteArray?.bytes.count
			let responseBodyData = NSData(bytes: responseBodyByteArray?.bytes, length: responseBodyByteArraySize!)
			
			switch statusCode {
			case 401:
				logger.error(String(HttpError.Unauthorized))
				let responseBodyString = String(data:responseBodyData, encoding: NSUTF8StringEncoding)
				logger.debug(responseBodyString!)
				completionHandler(error: HttpError.Unauthorized, data: data, status: statusCode, headers: convertHeaders(s4headers: s4headers))
				break
			case 404:
				logger.error(String(HttpError.NotFound))
				let responseBodyString = String(data:responseBodyData, encoding: NSUTF8StringEncoding)
				logger.debug(responseBodyString!)
				completionHandler(error: HttpError.NotFound, data: data, status: statusCode, headers: convertHeaders(s4headers: s4headers))
				break
			case 400 ... 599:
				logger.error(String(HttpError.ServerError))
				let responseBodyString = String(data:responseBodyData, encoding: NSUTF8StringEncoding)
				logger.debug(responseBodyString!)
				completionHandler(error: HttpError.ServerError, data: data, status: statusCode, headers: convertHeaders(s4headers: s4headers))
				break
			default:
				completionHandler(error: nil, data: responseBodyData, status: statusCode, headers: convertHeaders(s4headers: s4headers))
				break
			}
			
			// var bodyString = String(bytes: bodyByteArray!, encoding: NSUTF8StringEncoding)
			
		} else {
			completionHandler(error: HttpError.InvalidRequest, data: nil, status: nil, headers: nil)
		}
	}
	
	private class func convertHeaders(s4headers:S4.Headers) -> [String:String]{
		var headers:Dictionary<String, String> = [:]
		for (key, value) in s4headers{
			headers.updateValue(value[0], forKey: key.string)
		}
		return headers;
	}

}

