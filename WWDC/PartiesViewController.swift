//
//  PartiesViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 5/1/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import PINRemoteImage
import Crashlytics

class PartiesViewController: UIViewController, PartiesTableViewControllerDelegate {
    var partiesTableViewController: PartiesTableViewController?

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var partiesView: UIView!

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
        partiesTableViewController?.selectedSegmentIndex = segmentedControl.selectedSegmentIndex

        if let partiesTableViewController = partiesTableViewController, let refreshControl = partiesTableViewController.refreshControl {
            partiesTableViewController.tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        }
        partiesTableViewController?.refreshControl?.beginRefreshing()
        load() { [weak self] in
            self?.partiesTableViewController?.refreshControl?.endRefreshing()
        }

        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    @IBAction func updateSegment(_ sender: UISegmentedControl) {
        partiesTableViewController?.selectedSegmentIndex = sender.selectedSegmentIndex
        let userDefaults = UserDefaults.standard
        userDefaults.set(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        userDefaults.synchronize()
    }

    // MARK: PartiesTableViewControllerDelegate

    func load(_ completion: (() -> Void)?) {
        PartiesManager.sharedInstance.load() { [weak self] in
            self?.partiesTableViewController?.reloadData()
            completion?()
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PartiesTableViewController, segue.identifier == "partiesTVC" {
            vc.delegate = self
            partiesTableViewController = vc
        }
    }
}
