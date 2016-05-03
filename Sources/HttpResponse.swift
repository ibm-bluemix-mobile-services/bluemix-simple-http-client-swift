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

/*
public struct HttpResponse {
	public let logger = Logger(forName: "HttpClient")
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

*/