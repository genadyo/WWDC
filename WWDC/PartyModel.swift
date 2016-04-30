//
//  PartyModel.swift
//  SFParties
//
//  Created by Genady Okrain on 4/26/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import Foundation

struct Party {
    let objectId: String
    let icon: NSURL
    let logo: NSURL
    let title: String
    let startDate: NSDate
    let endDate: NSDate
    let details: String
    let address1: String
    let address2: String
    let address3: String
    let latitude: Double
    let longitude: Double
    let url: NSURL
    let date: String
    let hours: String

    var isGoing: Bool {
        get {
            return getVar("going")
        }
        set {
            setVar("going", bool: newValue)
        }
    }

    var isOld: Bool {
        get {
            return getVar("old")
        }
        set {
            setVar("old", bool: newValue)
        }
    }

    private func getVar(name: String) -> Bool {
        if let dict = NSUserDefaults.standardUserDefaults().objectForKey(name) as? [String: Bool], val = dict[objectId] {
            return val
        } else {
            return false
        }
    }

    private func setVar(name: String, bool: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if var dict = NSUserDefaults.standardUserDefaults().objectForKey(name) as? [String: Bool] {
            dict[objectId] = bool
            userDefaults.setObject(dict, forKey: name)
        } else {
            userDefaults.setObject([objectId: bool], forKey: name)
        }
        userDefaults.synchronize()
    }
}
