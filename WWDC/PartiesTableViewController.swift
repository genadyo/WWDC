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

    func buttonClicked(sender: UIButton) {
        performSegueWithIdentifier("map", sender: sender.tag)
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
            cell.separatorView.hidden = parties[indexPath.section].count == indexPath.row+1
            return cell
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 1 && parties.count == 0 {
            let navigationControllerHeight = navigationController?.navigationBar.frame.size.height ?? 0
            return UIScreen.mainScreen().bounds.size.height-2*(navigationControllerHeight+UIApplication.sharedApplication().statusBarFrame.size.height)
        } else {
            return 90
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        if !(segmentedControl.selectedSegmentIndex == 1 && parties.count == 0) && parties.count > section && parties[section].count > 0 {
            view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40.0))
            let bgView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40.0))
            bgView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            view.addSubview(bgView)
            let label = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width-22*2, 40.0))
            label.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightRegular)
            label.text = parties[section][0].date
            label.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            view.addSubview(label)
            let button = UIButton(type: .Custom)
            button.frame = CGRectMake(tableView.frame.size.width-36.0, 0.0, 20, 40.0)
            button.setImage(UIImage(named: "map"), forState: .Normal)
            button.addTarget(self, action: #selector(PartiesTableViewController.buttonClicked(_:)), forControlEvents: .TouchDown)
            button.tag = section
            view.addSubview(button)
        }
        return view
    }

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
