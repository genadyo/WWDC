//
//  PartiesTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import UIKit

class PartiesTableViewController: UITableViewController, PartyTableViewControllerDelegate {
    var parties = PartiesManager.sharedInstance.parties

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
        PartiesManager.sharedInstance.load() { [weak self] in
            self?.reloadData()
        }
    }

    @IBAction func updateSegment(sender: UISegmentedControl) {
        reloadData()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return parties.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parties[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("party", forIndexPath: indexPath) as! PartyTableViewCell
        cell.party = parties[indexPath.section][indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return parties[section][0].date
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("party", sender: indexPath)
    }

    // MARK: PartyTableViewControllerDelegate

    func reloadData() {
        if segmentedControl.selectedSegmentIndex == 0 {
            parties = PartiesManager.sharedInstance.parties
        } else {
            var pparties = [[Party]]()
            for p in parties {
                let filteredP = p.filter({ $0.isGoing })
                if filteredP.count > 0 {
                    pparties.append(filteredP)
                }
            }
            parties = pparties
        }
        tableView.reloadData()
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let indexPath = sender as? NSIndexPath else { return }

        if let nvc = segue.destinationViewController as? UINavigationController, vc = nvc.viewControllers[0] as? PartyTableViewController where segue.identifier == "party" {
            vc.delegate = self
            vc.party = parties[indexPath.section][indexPath.row]
        }
    }
}
