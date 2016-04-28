//
//  PartyTableViewCell.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import UIKit
import PINRemoteImage

class PartyTableViewCell: UITableViewCell {
    var party: Party? {
        didSet {
            if let party = party {
                titleLabel.text = party.title
                hoursLabel.text = party.hours
                iconImageView.pin_setImageFromURL(party.icon)
            }
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var goingView: WDCGoing!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
}
