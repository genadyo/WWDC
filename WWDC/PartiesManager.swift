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

    var JSON: [String: AnyObject]? {
        get {
            if let JSON = UserDefaults.standard.object(forKey: "results") as? [String: AnyObject] {
                return JSON
            } else {
                return nil
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "results")
            userDefaults.synchronize()
        }
    }

    lazy var parties: [[Party]] = {
        if let JSON = self.JSON {
            return ServerManager.processJSON(JSON as AnyObject)
        } else {
            return []
        }
    }()

    func load(_ completion: (() -> Void)?) {
        ServerManager.load("http://genady.okrain.com/parties/data.json") { [weak self] results, JSON in
            if let results = results {
                self?.parties = results
            }
            if let JSON = JSON as? [String: AnyObject] {
                self?.JSON = JSON
            }
            completion?()
        }
    }
}
