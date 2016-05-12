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
    case PUT = "PUT"
}

class Lyft {
    static let sharedInstance = Lyft()
    static let lyftAPIURL = "https://api.lyft.com"
    static let lyftAPIOAuthURL = "\(lyftAPIURL)/oauth"
    static let lyftAPIv1URL = "\(lyftAPIURL)/v1"
    internal var clientId: String?
    internal var clientSecret: String?
    internal var sandbox = false
    internal var completionHandler: ((success: Bool, error: NSError?) -> ())?
    private var accessToken: String?
    var refreshToken: String?

    internal static func fetchAccessToken(code: String?, refresh: Bool = false, revoke: Bool = false) {
        guard let clientId = sharedInstance.clientId, clientSecret = sharedInstance.clientSecret else {
            sharedInstance.completionHandler?(success: false, error: NSError(domain: "No clientId and clientSecret", code: 500, userInfo: nil))
            return
        }

        let u: String
        if revoke == true {
            u = "\(lyftAPIOAuthURL)/revoke_refresh_token"
        } else {
            u = "\(lyftAPIOAuthURL)/token"
        }

        if let url = NSURL(string: u) {
            let urlRequest = NSMutableURLRequest(URL: url)
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            urlRequest.HTTPMethod = HTTPMethod.POST.rawValue
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // Auth
            let authString: String
            if sharedInstance.sandbox == true {
                authString = "\(clientId):SANDBOX-\(clientSecret)"
            } else {
                authString = "\(clientId):\(clientSecret)"
            }
            let authData = authString.dataUsingEncoding(NSUTF8StringEncoding)
            if let authBase64 = authData?.base64EncodedStringWithOptions([]) {
                sessionConfiguration.HTTPAdditionalHeaders = ["Authorization" : "Basic \(authBase64)"]
            }

            do {
                let body: NSData
                if let code = code {
                    body = try NSJSONSerialization.dataWithJSONObject(["grant_type": "authorization_code", "code": code], options: [])
                } else if let refreshToken = sharedInstance.refreshToken where refresh == true {
                    body = try NSJSONSerialization.dataWithJSONObject(["grant_type": "refresh_token", "refresh_token": refreshToken], options: [])
                } else if let refreshToken = sharedInstance.refreshToken  where revoke == true {
                    body = try NSJSONSerialization.dataWithJSONObject(["token": refreshToken], options: [])
                } else {
                    body = try NSJSONSerialization.dataWithJSONObject(["grant_type": "client_credentials", "scope": "public"], options: [])
                }
                urlRequest.HTTPBody = body

                let session = NSURLSession(configuration: sessionConfiguration)
                let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
                    if let data = data {
                        do {
                            if let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], accessToken = response["access_token"] as? String {
                                sharedInstance.accessToken = accessToken
                                sharedInstance.refreshToken = response["refresh_token"] as? String
                                sharedInstance.completionHandler?(success: true, error: error)
                                return
                            } else {
                                sharedInstance.completionHandler?(success: false, error: NSError(domain: "No access_token", code: 502, userInfo: nil))
                                return
                            }
                        } catch {
                            sharedInstance.completionHandler?(success: false, error: NSError(domain: "Response JSON Serialization Failed", code: 503, userInfo: nil))
                            return
                        }
                    } else {
                        sharedInstance.completionHandler?(success: false, error: NSError(domain: "data == nil", code: 504, userInfo: nil))
                        return
                    }
                }
                task.resume()
            } catch {
                sharedInstance.completionHandler?(success: false, error: NSError(domain: "Body JSON Serialization Failed", code: 505, userInfo: nil))
                return
            }
        }
    }

    static func request(type: HTTPMethod, path: String, params: [String: AnyObject]?, completionHandler: ((response: [String: AnyObject]?, error: NSError?) -> ())?) {
        guard let accessToken = sharedInstance.accessToken else {
            completionHandler?(response: nil, error: NSError(domain: "No clientId and clientSecret", code: 500, userInfo: nil))
            return
        }

        var p = lyftAPIv1URL + path
        if let params = params as? [String: String] where type == .GET {
            p += urlQueryString(params: params)
        }

        if let url = NSURL(string: p) {
            let urlRequest = NSMutableURLRequest(URL: url)
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfiguration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
            urlRequest.HTTPMethod = type.rawValue
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                if let params = params  where type == .POST || type == .PUT {
                    let body = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                    urlRequest.HTTPBody = body
                }

                let session = NSURLSession(configuration: sessionConfiguration)
                let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
                    if let data = data {
                        if data.length == 0 {
                            completionHandler?(response: [:], error: error)
                            return
                        } else {
                            do {
                                if let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] {
                                    completionHandler?(response: response, error: error)
                                    return
                                } else {
                                    completionHandler?(response: nil, error: NSError(domain: "No response", code: 502, userInfo: nil))
                                    return
                                }
                            } catch {
                                completionHandler?(response: nil, error: NSError(domain: "Response JSON Serialization Failed", code: 503, userInfo: nil))
                                return
                            }
                        }
                    } else {
                        completionHandler?(response: nil, error: NSError(domain: "data == nil", code: 504, userInfo: nil))
                        return
                    }
                }
                task.resume()
            } catch {
                completionHandler?(response: nil, error: NSError(domain: "Body JSON Serialization Failed", code: 505, userInfo: nil))
                return
            }
        }
    }

    // MARK: Helper functions

    private static func urlQueryString(params params: [String: String]) -> String {
        var vars = [String]()
        for (key, value) in params {
            if let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) where value != "" {
                vars.append(key + "=" + encodedValue)
            }
        }
        return vars.isEmpty ? "" : "?" + vars.joinWithSeparator("&")
    }
}
