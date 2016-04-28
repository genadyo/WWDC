//
//  PartiesTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import UIKit

class PartiesTableViewController: UITableViewController {
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var goingSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        ServerManager.load("https://github.com/genadyo/WWDC/raw/master/data/data.json") { [weak self] parties, JSON in
            self?.tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return PartiesManager.sharedInstance.parties.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PartiesManager.sharedInstance.parties[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("party", forIndexPath: indexPath) as! PartyTableViewCell
        cell.party = PartiesManager.sharedInstance.parties[indexPath.section][indexPath.row]
        return cell
    }
}
