//
//  PartiesViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 5/1/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import PINRemoteImage

class PartiesViewController: UIViewController, PartiesTableViewControllerDelegate {
    var banner: Banner?
    var partiesTableViewController: PartiesTableViewController?

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var partiesView: UIView!
    @IBOutlet weak var bannerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        segmentedControl.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("selectedSegmentIndex")
        partiesTableViewController?.selectedSegmentIndex = segmentedControl.selectedSegmentIndex

        loadBanner()

        partiesTableViewController?.refreshControl?.beginRefreshing()
        load() { [weak self] in
            self?.partiesTableViewController?.refreshControl?.endRefreshing()
        }
    }

    func loadBanner() {
        if PartiesManager.sharedInstance.banners.count > 0 {
            let banner = PartiesManager.sharedInstance.banners[Int(arc4random_uniform(UInt32(PartiesManager.sharedInstance.banners.count)))]
            PINRemoteImageManager.sharedImageManager().downloadImageWithURL(banner.imageURL) { [weak self] result in
                dispatch_async(dispatch_get_main_queue()) {
                    if let image = result.image {
                        self?.banner = banner
                        self?.bannerButton.setImage(image, forState: .Normal)
                    }
                }
            }
            bannerButton.hidden = false
        } else {
            bannerButton.hidden = true
        }
    }

    @IBAction func updateSegment(sender: UISegmentedControl) {
        partiesTableViewController?.selectedSegmentIndex = sender.selectedSegmentIndex
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        userDefaults.synchronize()
    }

    @IBAction func openBanner(sender: UIButton) {
        if let url = banner?.url {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    // MARK: PartiesTableViewControllerDelegate

    func load(completion: (() -> Void)?) {
        PartiesManager.sharedInstance.load() { [weak self] in
            if self?.banner == nil {
                self?.loadBanner()
            }
            self?.partiesTableViewController?.reloadData()
            completion?()
        }
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PartiesTableViewController where segue.identifier == "partiesTVC" {
            vc.delegate = self
            partiesTableViewController = vc
        }
    }
}
