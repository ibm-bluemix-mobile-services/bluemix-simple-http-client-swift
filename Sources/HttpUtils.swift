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