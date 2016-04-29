import Foundation
import BluemixSimpleLogger
import HTTPSClient

public typealias NetworkRequestCompletionHandler = (error:HttpError?, data:NSData?, status:Int?, headers: [String:String]?) -> Void
internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

public struct HttpResponse{
	public let logger = Logger(forName: "HttpResponse")
	public var error: HttpError?
	public var response: S4.Response?
	
	public var statusCode:Int{
		get{
			if let code = response?.status.statusCode{
				return code
			} else {
				return 0
			}
		}
	}
	
	public var allHeaderFields: [String:String]?{
		get {
			if let headers = response?.headers{
				return HttpUtils.s4headersToNSURLHeaders(s4headers: headers)
			} else {
				return [:]
			}
		}
	}
	
	public var bodyAsData: NSData? {
		if var response = response, let responseBodyByteArray = try? response.body.becomeBuffer(){
			return HttpUtils.byteArrayToNSData(responseBodyByteArray.bytes)
		} else{
			return nil
		}
	}
	
	public var bodyAsString: String?{
		if let responseBodyData = self.bodyAsData {
			return String(data:responseBodyData, encoding: NSUTF8StringEncoding)
		} else {
			return nil
		}
	}
	
	public init(error:HttpError? = nil, response:S4.Response? = nil){
		self.error = error
		
		if let response = response {
			self.response = response
			
			switch response.status.statusCode {
			case 401:
				self.error = HttpError.Unauthorized
				logger.error(String(HttpError.Unauthorized))
				logger.debug(self.bodyAsString!)
			case 404:
				self.error = HttpError.NotFound
				logger.error(String(HttpError.NotFound))
				logger.debug(self.bodyAsString!)
			case 400 ... 599:
				self.error = HttpError.ServerError
				logger.error(String(HttpError.ServerError))
				logger.debug(self.bodyAsString!)
			default:
				break
			}
		}
	}
	
}

///	Used to indicate various failure types that might occur during HTTPS operations
public enum HttpError: Int, ErrorProtocol{
	/**
	Indicates a failure during connection attempt. Since response and data is not available in this case an error message might be provided
	
	- Parameter message: An optional description of failure reason
	*/
	case ConnectionFailure = 1
	
	/// Indicates a resource not being available on server. Returned in case of HTTP 404 status
	case NotFound = 2
	
	/// Indicates a missing authorization or authentication failure. Returned in case of HTTP 401 status
	case Unauthorized = 3
	
	/// Indicates an error reported by server. Retruned in cases of HTTP 4xx and 5xx statuses which are not handled separately
	case ServerError = 4
	
	/// Indicates an invalid Uri passed to the BluemixHTTPSClient
	case InvalidUri = 5
	
	/// Indicates that HTTP client was unable to send request
	case InvalidRequest = 6
	
}

public class HTTPSClient{
	public static let logger = Logger(forName: "BluemixHTTPSClient")
	
	/// Send a GET request
	public class func get(url:String, headers:[String:String]? = nil) -> HttpResponse{
		return HTTPSClient.sendRequest(url: url, method: .get , headers: headers)
	}
	
	/// Send a PUT request
	public class func put(url:String, headers:[String:String]? = nil, data:NSData? = nil) -> HttpResponse{
		return HTTPSClient.sendRequest(url: url, method: .put , headers: headers, data: data)
	}
	
	/// Send a DELETE request
	public class func delete(url:String, headers:[String:String]? = nil) -> HttpResponse{
		return HTTPSClient.sendRequest(url: url, method: .delete , headers: headers)
	}
	
	/// Send a POST request
	public class func post(url:String, headers:[String:String]? = nil, data:NSData? = nil) -> HttpResponse{
		return HTTPSClient.sendRequest(url: url, method: .post , headers: headers, data: data)
	}
	
	/// Send a HEAD request
	public class func head(url:String, headers:[String:String]? = nil) -> HttpResponse{
		return HTTPSClient.sendRequest(url: url, method: .head , headers: headers)
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
	private class func sendRequest(url:String, method:S4.Method, headers:[String:String]? = nil, data: NSData? = nil) -> HttpResponse{
		var requestUri = try? URI(url)
		
		guard requestUri != nil else {
			return HttpResponse(error: HttpError.InvalidUri)
		}
		
		if requestUri!.port == nil{
			requestUri!.port = requestUri?.scheme == "https" ? 443 : 80
		}
		
		let client = try? Client(uri:requestUri!)
		guard client != nil else {
			return HttpResponse(error: HttpError.InvalidUri)
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
		
		if let data = data {
			let byteArray = HttpUtils.NSDataToByteArray(data)
			response = try? client!.send(method: method, uri: requestUri!.path!, headers: s4headers, body: Data(byteArray))
		} else {
			response = try? client!.send(method: method, uri: requestUri!.path!, headers: s4headers)
		}
		
		if let response = response {
			return HttpResponse(response: response)
		} else {
			logger.error(String(HttpError.InvalidRequest))
			logger.debug(requestUri.debugDescription)
			return HttpResponse(error: HttpError.InvalidRequest)
		}
	}
	
}

public class HttpUtils{
	public class func NSDataToByteArray(_ data:NSData) -> [Byte]{
		let dataLength = data.length
		let bytesCount = dataLength/sizeof(Byte)
		var byteArray:[Byte] = []
		byteArray = [Byte](repeating:0, count: bytesCount)
		data.getBytes(&byteArray, length: dataLength)
		return byteArray
	}
	
	public class func byteArrayToNSData(_ byteArray:[Byte]) -> NSData {
		return NSData(bytes: byteArray, length: byteArray.count)
	}
	
	private class func s4headersToNSURLHeaders(s4headers:S4.Headers) -> [String:String]{
		var headers:Dictionary<String, String> = [:]
		for (key, value) in s4headers{
			headers.updateValue(value[0], forKey: key.string)
		}
		return headers;
	}
	
	static func contentType(from fileName:String, otherwise:String = "text/plain") -> String{
		if fileName.ends(with: ".txt"){
			return "text/plain"
		} else if fileName.ends(with: ".jpg"){
			return "image/jpeg"
		} else if fileName.ends(with: ".png"){
			return "image/png"
		}
		return otherwise
	}

}