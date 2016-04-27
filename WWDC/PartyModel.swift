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
}
