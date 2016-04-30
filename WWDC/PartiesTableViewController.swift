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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        segmentedControl.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("selectedSegmentIndex")

        reloadData()
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }

    @IBAction func updateSegment(sender: UISegmentedControl) {
        reloadData()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        userDefaults.synchronize()
    }

    @IBAction func refresh(sender: UIRefreshControl?) {
        PartiesManager.sharedInstance.load() { [weak self] in
            self?.reloadData()
            sender?.endRefreshing()
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 && parties.count == 0 {
            return 1
        } else {
            return parties.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 && parties.count == 0 {
            return 1
        } else {
            return parties[section].count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 1 && parties.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("empty", forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("party", forIndexPath: indexPath) as! PartyTableViewCell
            cell.party = parties[indexPath.section][indexPath.row]
            return cell
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if parties.count > section && parties[section].count > 0 {
            return parties[section][0].date
        } else {
            return nil
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("party", sender: indexPath)
    }

    // MARK: PartyTableViewControllerDelegate

    func reloadData() {
        if segmentedControl.selectedSegmentIndex == 0 {
            parties = PartiesManager.sharedInstance.parties
            tableView.scrollEnabled = true
        } else {
            var pparties = [[Party]]()
            for p in parties {
                let filteredP = p.filter({ $0.isGoing })
                if filteredP.count > 0 {
                    pparties.append(filteredP)
                }
            }
            parties = pparties
            tableView.scrollEnabled = parties.count > 0
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
