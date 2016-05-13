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
            return ServerManager.processJSON(JSON).parties
        } else {
            return []
        }
    }()

    lazy private(set) var banners: [Banner] = {
        if let JSON = self.JSON {
            return ServerManager.processJSON(JSON).banners
        } else {
            return []
        }
    }()

    lazy private(set) var promotion: Bool = {
        if let JSON = self.JSON {
            return ServerManager.processJSON(JSON).promotion
        } else {
            return false
        }
    }()

    func load(completion: (() -> Void)?) {
        // redirect to https://gitcdn.link/repo/genadyo/WWDC/master/data/data.json
        ServerManager.load("https://caltrain.okrain.com/parties") { [weak self] results, JSON in
            if let results = results {
                self?.parties = results.parties
                self?.banners = results.banners
                self?.promotion = results.promotion
            }
            if let JSON = JSON as? [String: AnyObject] {
                self?.JSON = JSON
            }
            completion?()
        }
    }
}
