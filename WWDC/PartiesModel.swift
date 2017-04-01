//
//  PartyModel.swift
//  SFParties
//
//  Created by Genady Okrain on 4/26/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

struct Party {
    let objectId: String
    let icon: URL
    let logo: URL
    let title: String
    let startDate: Date
    let endDate: Date
    let details: String
    let address1: String
    let address2: String
    let address3: String
    let latitude: Double
    let longitude: Double
    let url: URL
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

    fileprivate func getVar(_ name: String) -> Bool {
        if let dict = UserDefaults.standard.object(forKey: name) as? [String: Bool], let val = dict[objectId] {
            return val
        } else {
            return false
        }
    }

    fileprivate func setVar(_ name: String, bool: Bool) {
        let userDefaults = UserDefaults.standard
        if var dict = UserDefaults.standard.object(forKey: name) as? [String: Bool] {
            dict[objectId] = bool
            userDefaults.set(dict, forKey: name)
        } else {
            userDefaults.set([objectId: bool], forKey: name)
        }
        userDefaults.synchronize()
    }
}

struct Banner {
    let objectId: String
    let imageURL: URL
    let url: URL
}
