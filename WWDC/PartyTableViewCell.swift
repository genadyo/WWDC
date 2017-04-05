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

                if party.promoted == true {
                    backgroundColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
                    titleLabel.textColor = .white
                    hoursLabel.textColor = UIColor(white: 1.0, alpha: 0.9)
                } else {
                    backgroundColor = .white
                    titleLabel.textColor = .black
                    hoursLabel.textColor = UIColor(red: 171.0/255.0, green: 171.0/255.0, blue: 171.0/255.0, alpha: 1.0)
                }
            }
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if party?.promoted == true {
            badgeView.backgroundColor = .white
        } else {
            badgeView.backgroundColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var goingImageView: UIImageView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
}
