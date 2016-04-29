//
//  PartyTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/28/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import UIKit

class PartyTableViewController: UITableViewController {
    var party: Party!

    @IBOutlet weak var goingButton: UIButton!

    @IBOutlet weak var logoImageView: UIImageView! {
        didSet {
            logoImageView.pin_setImageFromURL(party.logo)
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = party.title
        }
    }

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var mapView: UIButton!

    @IBOutlet weak var address1Label: UILabel! {
        didSet {
            address1Label.text = party.address1
        }
    }

    @IBOutlet weak var address2Label: UILabel!  {
        didSet {
            address2Label.text = party.address2
        }
    }

    @IBOutlet weak var address3Label: UILabel!  {
        didSet {
            address3Label.text = party.address3
        }
    }
}
