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

/// Used for specifying an Http Resource that the request will be made to
public struct HttpResource{

	/// Request schema, should be either http or https
	let schema:String

	/// Resource host name, e.g. www.example.com
	let host:String

	/// Resource port, e.g. 80
	let port:String?

	/// Resource path, e.g. /my/resource/id/123
	let path:String

	var uri:String {
		get {
			var value = schema + "://" + host
			if let port = port { value += ":" + port }
			value += path
			return value
	  }
	}

	/**
	Initialize the HttpResource by specifying all properties

	- Parameter schema: Request schema, should be either http or https
	- Parameter host: Resource host name, e.g. www.example.com
	- Parameter port: Resource port, e.g. 80
	- Parameter path: Resource path, e.g. /my/resource/id/123
	*/

	public init(schema:String, host: String, port: String? = nil, path: String = "") {
		self.schema = schema
		self.host = host
		self.port = port
		self.path = path
	}

	/**
	Create a new HttpResource by adding components to path

	- Parameter pathComponent: components to add
	*/
	public func resourceByAddingPathComponent(pathComponent:String) -> HttpResource {
		return HttpResource(schema: self.schema, host: self.host, port: self.port, path: self.path + pathComponent)
	}
}
