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
                iconImageView.pin_setImageFromURL(party.icon)
                hoursLabel.text = party.hours
                goingImageView.hidden = !party.isGoing
                badgeView.hidden = party.isOld
                titleLabel.text = party.title
            }
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var goingImageView: UIImageView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
}
