//
//  PartyTableViewCell.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import PINRemoteImage

class PartyTableViewCell: UITableViewCell {
    var party: Party? {
        didSet {
            if let party = party {
                iconImageView.image = nil
                iconImageView.pin_setImage(from: party.icon)
                hoursLabel.text = party.hours
                goingImageView.isHidden = !party.isGoing
                badgeView.isHidden = party.isOld
                titleLabel.text = party.title
            }
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        badgeView.backgroundColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var goingImageView: UIImageView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
}
