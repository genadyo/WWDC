//
//  PartiesManager.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import Foundation

class PartiesManager {
    static let sharedInstance = PartiesManager()

    private var JSON: [AnyObject]? {
        get {
            if let JSON = NSUserDefaults.standardUserDefaults().objectForKey("parties") as? [AnyObject] {
                return JSON
            } else {
                return nil
            }
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: "parties")
            userDefaults.synchronize()
        }
    }

    lazy private(set) var parties: [[Party]] = {
        if let JSON = self.JSON {
            return ServerManager.processJSON(JSON)
        } else {
            return []
        }
    }()

    func load(completion: (() -> Void)?) {
        ServerManager.load("https://github.com/genadyo/WWDC/raw/master/data/data.json") { [weak self] parties, JSON in
            self?.parties = parties
            self?.JSON = JSON as? [AnyObject]
            completion?()
        }
    }
}
