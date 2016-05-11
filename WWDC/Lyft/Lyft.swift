//
//  Lyft.swift
//  SFParties
//
//  Created by Genady Okrain on 5/3/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

class Lyft {
    static let sharedInstance = Lyft()
    private var clientId: String?
    private var clientSecret: String?
    private var sandbox = false
    private var accessToken: String?
    private var completionHandler: ((success: Bool, error: NSError?) -> ())?

    static func set(clientId clientId: String, clientSecret: String, sandbox: Bool? = nil) {
        sharedInstance.clientId = clientId
        sharedInstance.clientSecret = clientSecret
        if let sandbox = sandbox {
            sharedInstance.sandbox = sandbox
        }
    }

    static func login(scope scope: String, state: String = "", completionHandler: ((success: Bool, error: NSError?) -> ())?) {
        guard let clientId = sharedInstance.clientId, _ = sharedInstance.clientSecret else { return }

        let string = "https://api.lyft.com/oauth/authorize?client_id=\(clientId)&response_type=code&scope=\(scope)&state=\(state)"

        sharedInstance.completionHandler = completionHandler

        if let url = NSURL(string: string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    func openURL(url: NSURL) -> Bool {
        guard let _ = clientId, _ = clientSecret else { return false }
        guard let code = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?.queryItems?.filter({ $0.name == "code" }).first?.value else { return false }

        fetchAccessToken(code)

        return true
    }

    func fetchAccessToken(code: String) {
        guard let clientId = clientId, clientSecret = clientSecret else { return }

        if let url = NSURL(string: "https://api.lyft.com/oauth/token") {
            let urlRequest = NSMutableURLRequest(URL: url)
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfiguration.HTTPAdditionalHeaders = ["Content-Type": "application/json"]

            // Post
            urlRequest.HTTPMethod = "POST"

            // JSON
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")


            // Auth
            let authString: String
            if sandbox == true {
                authString = "\(clientId):SANDBOX-\(clientSecret)"
            } else {
                authString = "\(clientId):\(clientSecret)"
            }
            let authData = authString.dataUsingEncoding(NSUTF8StringEncoding)
            if let authBase64 = authData?.base64EncodedStringWithOptions([]) {
                sessionConfiguration.HTTPAdditionalHeaders = ["Authorization" : "Basic \(authBase64)"]
            }

            do {
                // Body
                let body = try NSJSONSerialization.dataWithJSONObject(["grant_type": "authorization_code", "code": code], options: [])
                urlRequest.HTTPBody = body

                let session = NSURLSession(configuration: sessionConfiguration)
                let task = session.dataTaskWithRequest(urlRequest) { [weak self] data, response, error in
                    if let data = data {
                        do {
                            if let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], accessToken = response["access_token"] as? String {
                                self?.accessToken = accessToken
                                self?.completionHandler?(success: true, error: nil)

                            } else {
                                print("No access_token")
                            }
                        } catch {
                            print("Response JSON Serialization Failed")
                        }
                    } else {
                        print("data == nil")
                    }
                }
                task.resume()
            } catch {
                print("Body JSON Serialization Failed")
            }
        }
    }

    static func request(type: HTTPMethod, path: String, params: [String: AnyObject]?, completionHandler: ((response: [String: AnyObject]?, error: NSError?) -> ())?) {
        guard let accessToken = sharedInstance.accessToken else { return }

        var p = "https://api.lyft.com/v1" + path
        if let params = params as? [String: String] where type == .GET {
            p += buildQueryString(fromDictionary: params)
        }

        if let url = NSURL(string: p) {
            let urlRequest = NSMutableURLRequest(URL: url)
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfiguration.HTTPAdditionalHeaders = ["Content-Type": "application/json", "Authorization": "Bearer \(accessToken)"]

            // Post
            urlRequest.HTTPMethod = type.rawValue

            do {
                // Body
                if let params = params  where type == .POST {
                    let body = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                    urlRequest.HTTPBody = body
                }

                let session = NSURLSession(configuration: sessionConfiguration)
                let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
                    if let data = data {
                        if data.length == 0 {
                            completionHandler?(response: [:], error: nil)
                        } else {
                            do {
                                if let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] {
                                    completionHandler?(response: response, error: nil)
                                } else {
                                    print("No response")
                                }
                            } catch {
                                print("Response JSON Serialization Failed")
                            }
                        }
                    } else {
                        print("data == nil")
                    }
                }
                task.resume()
            } catch {
                print("Body JSON Serialization Failed")
            }
        }
    }

    static func buildQueryString(fromDictionary parameters: [String: String]) -> String {
        var urlVars:[String] = []

        for (k, value) in parameters {
            if let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) where value != "" {
                urlVars.append(k + "=" + encodedValue)
            }
        }

        return urlVars.isEmpty ? "" : "?" + urlVars.joinWithSeparator("&")
    }


}
