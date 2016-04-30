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

        PartiesManager.sharedInstance.load() { [weak self] in
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

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return PartiesManager.sharedInstance.parties[section][0].date
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("party", sender: indexPath)
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let indexPath = sender as? NSIndexPath else { return }

        if let nvc = segue.destinationViewController as? UINavigationController, vc = nvc.viewControllers[0] as? PartyTableViewController where segue.identifier == "party" {
            vc.party = PartiesManager.sharedInstance.parties[indexPath.section][indexPath.row]
        }
    }
}
