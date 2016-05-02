///	Used to indicate various failure types that might occur during HTTP operations
/// All 2xx and 3xx statuses are considered success, all 4xx and 5xx statuses are considered errors
public enum HttpError: Int, ErrorProtocol{
	
	/// Indicates a failure during connection attempt. Connection could not be established
	case ConnectionFailure = 1
	
	/// Indicates an invalid Uri
	case InvalidUri = 2
	
	/// Indicates HTTP client being unable to send request
	case InvalidRequest = 3
	
	/// Failed parsing response
	case FailedParsingResponse = 4

	/// Indicates a missing authorization or authentication failure. Returned in case of HTTP 401 status
	case Unauthorized = 401
	
	/// Indicates a resource not being available on server. Returned in case of HTTP 404 status
	case NotFound = 404
	
	/// Indicates an error reported by server. Retruned in cases of HTTP 4xx and 5xx statuses which are not handled separately
	case ServerError = 500
}