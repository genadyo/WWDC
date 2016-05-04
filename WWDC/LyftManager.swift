//
//  LyftManager.swift
//  SFParties
//
//  Created by Genady Okrain on 5/3/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

class LyftManager {
    static let sharedInstance = LyftManager()
    private var clientId: String?
    private var clientSecret: String?

    func setClientId(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    func openLyft(scope scope: String, state: String) {
        guard let clientId = clientId, _ = clientSecret else { return }

        if let url = NSURL(string: "https://api.lyft.com/oauth/authorize?client_id=\(clientId)&response_type=code&scope=\(scope)&state=\(state)") {
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

            // Post
            urlRequest.HTTPMethod = "POST"

            // JSON
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")


            // Auth
            let authString = "\(clientId):\(clientSecret)"
            let authData = authString.dataUsingEncoding(NSUTF8StringEncoding)
            if let authBase64 = authData?.base64EncodedStringWithOptions([]) {
                sessionConfiguration.HTTPAdditionalHeaders = ["Authorization" : "Basic \(authBase64)"]
            }

            do {
                // Body
                let body = try NSJSONSerialization.dataWithJSONObject(["grant_type": "authorization_code", "code": code], options: [])
                urlRequest.HTTPBody = body

                let session = NSURLSession(configuration: sessionConfiguration)
                let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
                    if let data = data {
                        do {
                            if let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], accessToken = response["access_token"] {
                                print(accessToken)
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
}
