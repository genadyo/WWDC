//
//  PartiesTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import CoreLocation

protocol PartiesTableViewControllerDelegate {
    func load(completion: (() -> Void)?)
}

class PartiesTableViewController: UITableViewController, PartyTableViewControllerDelegate, UIViewControllerPreviewingDelegate {
    var selectedSegmentIndex = 0 {
        didSet {
            reloadData()
        }
    }

    var delegate: PartiesTableViewControllerDelegate?

    private var parties = PartiesManager.sharedInstance.parties

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Peek & Pop
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
    }

    @IBAction func refresh(sender: UIRefreshControl?) {
        delegate?.load() {
            sender?.endRefreshing()
        }
    }

    func buttonClicked(sender: UIButton) {
        performSegueWithIdentifier("map", sender: sender)
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return 1
        } else {
            return parties.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return 1
        } else {
            return parties[section].count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if selectedSegmentIndex == 1 && parties.count == 0 {
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
        if selectedSegmentIndex == 1 && parties.count == 0 {
            let navigationControllerHeight = navigationController?.navigationBar.frame.size.height ?? 0
            return UIScreen.mainScreen().bounds.size.height-navigationControllerHeight-UIApplication.sharedApplication().statusBarFrame.size.height
        } else {
            return 75
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return 0
        } else {
            return 40
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        if !(selectedSegmentIndex == 1 && parties.count == 0) && parties.count > section && parties[section].count > 0 {
            view = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.size.width, 40.0))
            view.autoresizingMask = .FlexibleWidth

            let bgView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.size.width, 40.0))
            bgView.autoresizingMask = .FlexibleWidth
            bgView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            view.addSubview(bgView)

            let label = UILabel(frame: CGRectMake(8.0, 0.0, tableView.frame.size.width-22.0*2, 40.0))
            label.autoresizingMask = .FlexibleRightMargin
            label.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightRegular)
            label.text = parties[section][0].date
            label.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            view.addSubview(label)

            let mapImageView = UIImageView(image: UIImage(named: "map"))
            mapImageView.autoresizingMask = .FlexibleLeftMargin
            mapImageView.frame = CGRectMake(tableView.frame.size.width-33.0, 6.0, 20.0, 28.0)
            view.addSubview(mapImageView)

            let button = UIButton(type: .Custom)
            button.autoresizingMask = .FlexibleWidth
            button.frame = view.frame
            button.addTarget(self, action: #selector(PartiesTableViewController.buttonClicked(_:)), forControlEvents: .TouchDown)
            button.tag = section
            view.addSubview(button)
        }
        return view
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        performSegueWithIdentifier("party", sender: indexPath)
    }

    // MARK: PartyTableViewControllerDelegate

    func reloadData() {
        if selectedSegmentIndex == 0 {
            parties = PartiesManager.sharedInstance.parties
            tableView.scrollEnabled = true
        } else {
            var pparties = [[Party]]()
            for p in PartiesManager.sharedInstance.parties {
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

    // MARK: UIViewControllerPreviewingDelegate

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) as? PartyTableViewCell, nvc = storyboard?.instantiateViewControllerWithIdentifier("partyNVC") as? PartyNavigationController, vc = nvc.viewControllers[0] as? PartyTableViewController where tableView.bounds.contains(tableView.rectForRowAtIndexPath(indexPath)) else { return nil }
        previewingContext.sourceRect = cell.frame
        vc.party = parties[indexPath.section][indexPath.row]
        return nvc
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? PartyNavigationController, vc = nvc.viewControllers[0] as? PartyTableViewController, indexPath = sender as? NSIndexPath where segue.identifier == "party" {
            vc.delegate = self
            vc.party = parties[indexPath.section][indexPath.row]
        } else if let nvc = segue.destinationViewController as? UINavigationController, vc = nvc.viewControllers[0] as? MapDayViewController, button = sender as? UIButton where segue.identifier == "map" {
            vc.navigationItem.title = parties[button.tag][0].date
            vc.parties = parties[button.tag]
        }
    }
}
