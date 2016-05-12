//
//  LyftOAuth.swift
//  SFParties
//
//  Created by Genady Okrain on 5/11/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

extension Lyft {
    // Initialize clientId & clientSecret
    static func set(clientId clientId: String, clientSecret: String, sandbox: Bool? = nil) {
        sharedInstance.clientId = clientId
        sharedInstance.clientSecret = clientSecret
        sharedInstance.sandbox = sandbox ?? false
    }

    // 3-Legged flow for accessing user-specific endpoints
    static func userLogin(scope scope: String, state: String = "", completionHandler: ((success: Bool, error: NSError?) -> ())?) {
        guard let clientId = sharedInstance.clientId, _ = sharedInstance.clientSecret else { return }

        let string = "\(lyftAPIOAuthURL)/authorize?client_id=\(clientId)&response_type=code&scope=\(scope)&state=\(state)"

        sharedInstance.completionHandler = completionHandler

        if let url = NSURL(string: string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    // Client Credentials (2-legged) flow for public endpoints
    static func publicLogin(completionHandler: ((success: Bool, error: NSError?) -> ())?) {
        guard let _ = sharedInstance.clientId, _ = sharedInstance.clientSecret else { return }

        sharedInstance.completionHandler = completionHandler

        fetchAccessToken(nil)
    }

    // Refreshing the access token
    static func refreshToken(completionHandler: ((success: Bool, error: NSError?) -> ())?) {
        guard let _ = sharedInstance.clientId, _ = sharedInstance.clientSecret else { return }

        sharedInstance.completionHandler = completionHandler

        fetchAccessToken(nil, refresh: true)
    }

    // Revoking the access token
    static func revokeToken(completionHandler: ((success: Bool, error: NSError?) -> ())?) {
        guard let _ = sharedInstance.clientId, _ = sharedInstance.clientSecret else { return }

        sharedInstance.completionHandler = completionHandler

        fetchAccessToken(nil, refresh: false, revoke: true)
    }

    // func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool
    static func openURL(url: NSURL) -> Bool {
        guard let _ = sharedInstance.clientId, _ = sharedInstance.clientSecret else { return false }
        guard let code = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?.queryItems?.filter({ $0.name == "code" }).first?.value else { return false }

        fetchAccessToken(code)
        
        return true
    }
}
