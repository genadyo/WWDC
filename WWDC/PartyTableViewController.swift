//
//  PartyTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/28/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class PartyTableViewController: UITableViewController, SFSafariViewControllerDelegate {
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

    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            detailsLabel.text = party.details
        }
    }

    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.text = party.date
        }
    }

    @IBOutlet weak var hoursLabel: UILabel! {
        didSet {
            hoursLabel.text = party.hours
        }
    }

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            var region = MKCoordinateRegion()
            region.center.latitude = party.latitude
            region.center.longitude = party.longitude
            region.span.latitudeDelta = 0.0075
            region.span.longitudeDelta = 0.0075
            mapView.setRegion(region, animated: false)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(party.latitude, party.longitude)
            mapView.addAnnotation(annotation)
        }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Self sizing cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    @IBAction func openMaps(sender: UIButton) {

    }

    @IBAction func openLyft(sender: UIButton) {

    }

    @IBAction func openWeb(sender: UIButton) {
        let safariViewController = SFSafariViewController(URL: party.url)
        safariViewController.delegate = self
        presentViewController(safariViewController, animated: true, completion: nil)
    }

    // MARK: SFSafariViewControllerDelegate

    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
