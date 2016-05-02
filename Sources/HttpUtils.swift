/*

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

public static func contentType(fromFilename fileName:String, otherwise:String = "text/plain") -> String{
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
*/