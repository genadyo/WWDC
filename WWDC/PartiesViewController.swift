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
    var banner: Banner?
    var partiesTableViewController: PartiesTableViewController?

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var partiesView: UIView!
    @IBOutlet weak var bannerButton: UIButton!

    fileprivate let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
        partiesTableViewController?.selectedSegmentIndex = segmentedControl.selectedSegmentIndex

//        loadBanner()

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

//    func loadBanner() {
//        if PartiesManager.sharedInstance.banners.count > 0 {
//            _ = PartiesManager.sharedInstance.banners[Int(arc4random_uniform(UInt32(PartiesManager.sharedInstance.banners.count)))]
////            PINRemoteImageManager.shared().downloadImage(with: banner.imageURL) { [weak self] result in
////                DispatchQueue.main.async {
////                    if let image = result.image {
////                        self?.banner = banner
////                        self?.bannerButton.setImage(image, for: UIControlState())
////                    }
////                }
////            }
//            bannerButton.isHidden = false
//        } else {
//            bannerButton.isHidden = true
//        }
//    }

    @IBAction func updateSegment(_ sender: UISegmentedControl) {
        partiesTableViewController?.selectedSegmentIndex = sender.selectedSegmentIndex
        let userDefaults = UserDefaults.standard
        userDefaults.set(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        userDefaults.synchronize()
    }

    @IBAction func openBanner(_ sender: UIButton) {
        if let url = banner?.url, let objectId = banner?.objectId {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Answers.logCustomEvent(withName: "Banner", customAttributes: ["objectId": objectId])
        }
    }

    // MARK: PartiesTableViewControllerDelegate

    func load(_ completion: (() -> Void)?) {
        PartiesManager.sharedInstance.load() { [weak self] in
//            if self?.banner == nil {
//                self?.loadBanner()
//            }
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
