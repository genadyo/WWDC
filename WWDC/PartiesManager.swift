//
//  PartiesManager.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

class PartiesManager {
    static let sharedInstance = PartiesManager()

    private var JSON: [String: AnyObject]? {
        get {
            if let JSON = NSUserDefaults.standardUserDefaults().objectForKey("results") as? [String: AnyObject] {
                return JSON
            } else {
                return nil
            }
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: "results")
            userDefaults.synchronize()
        }
    }

    lazy private(set) var parties: [[Party]] = {
        if let JSON = self.JSON {
            return ServerManager.processJSON(JSON).0
        } else {
            return []
        }
    }()

    lazy private(set) var banners: [Banner] = {
        if let JSON = self.JSON {
            return ServerManager.processJSON(JSON).1
        } else {
            return []
        }
    }()

    func load(completion: (() -> Void)?) {
        ServerManager.load("https://gitcdn.link/repo/genadyo/WWDC/master/data/data.json") { [weak self] results, JSON in
            self?.parties = results.0
            self?.banners = results.1
            self?.JSON = JSON as? [String: AnyObject]
            completion?()
        }
    }
}
