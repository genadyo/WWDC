//
//  ServerManager.swift
//  Caltrain
//
//  Created by Genady Okrain on 3/3/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

class ServerManager: NSObject {
    static func load(url: String, completion: ((parties: AnyObject?, JSON: AnyObject?) -> Void)?) {
        if let url = NSURL(string: url) {
            let request = NSURLRequest(URL: url)
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) { data, _, _ in
                dispatch_async(dispatch_get_main_queue()) {
                    if let data = data {
                        do {
                            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            print(response)
                            completion?(parties: nil, JSON: response)
                        } catch {
                            completion?(parties: nil, JSON: nil)
                        }
                    } else {
                        completion?(parties: nil, JSON: nil)
                    }
                }
            }
            task.resume()
        } else {
            completion?(parties: nil, JSON: nil)
        }
    }
}