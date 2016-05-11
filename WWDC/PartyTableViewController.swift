//
//  PartyTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/28/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import Keys
import Contacts
import EventKitUI
import Crashlytics

protocol PartyTableViewControllerDelegate {
    func reloadData()
}

class PartyTableViewController: UITableViewController, SFSafariViewControllerDelegate, EKEventEditViewDelegate {
    var party: Party!
    var delegate: PartyTableViewControllerDelegate?

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
            let font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightLight)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 20.0
            paragraphStyle.maximumLineHeight = 20.0
            paragraphStyle.minimumLineHeight = 20.0
            let color = UIColor(red: 146.0/255.0, green: 146.0/255.0, blue: 146.0/255.0, alpha: 1.0)
            let attributedDetails = NSMutableAttributedString(string: party.details, attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: color])
            detailsLabel.attributedText = attributedDetails;
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

    @IBOutlet weak var lyftButton: UIButton! {
        didSet {
            if UI_USER_INTERFACE_IDIOM() == .Pad {
                lyftButton.hidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Going/Old
        goingButton.selected = party.isGoing
        party.isOld = true
        delegate?.reloadData()

        // Self sizing cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.row == 6 { // Xcode Bug #2
            cell.backgroundColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        }
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    @IBAction func updateGoing(sender: UIButton) {
        party.isGoing = !party.isGoing
        goingButton.selected = party.isGoing
        delegate?.reloadData()
    }

    @IBAction func openMaps(sender: AnyObject) {
        let coordinate = CLLocationCoordinate2DMake(party.latitude, party.longitude)

        var addressDictionary = [String: AnyObject]()
        addressDictionary[CNPostalAddressCountryKey] = "United States"
        addressDictionary[CNPostalAddressStreetKey] = party.address2
        let address3Split = party.address3.componentsSeparatedByString(", ")
        if address3Split.count == 2 {
            addressDictionary[CNPostalAddressCityKey] = address3Split[0]
            let address3SplitSplit = address3Split[1].componentsSeparatedByString(" ")
            if address3SplitSplit.count == 2 {
                addressDictionary[CNPostalAddressStateKey] = address3SplitSplit[0]
                addressDictionary[CNPostalAddressPostalCodeKey] = address3SplitSplit[1]
            }
        }

        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary))
        item.name = party.title
        item.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking, MKLaunchOptionsMapTypeKey: MKMapType.Standard.rawValue])
    }

    @IBAction func openLyft(sender: AnyObject) {
        Lyft.login(scope: "rides.request") { success, error in
            if success == true {
                // promo
            }
        }
        Answers.logCustomEventWithName("Lyft", customAttributes: ["objectId": party.objectId])
    }

    @IBAction func openWeb(sender: AnyObject) {
        let safariViewController = SFSafariViewController(URL: party.url)
        safariViewController.delegate = self
        presentViewController(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction func openCal(sender: UITapGestureRecognizer) {
        let eventStore = EKEventStore()
        let authorizationStatus = EKEventStore.authorizationStatusForEntityType(.Event)
        let needsToRequestAccessToEventStore = authorizationStatus == .NotDetermined

        if needsToRequestAccessToEventStore == true {
            eventStore.requestAccessToEntityType(.Event) { [weak self] granted, error in
                if granted == true {
                    self?.addEvent()
                } else if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        } else {
            let granted = authorizationStatus == .Authorized
            if granted == true {
                addEvent()
            } else if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }

    private func addEvent() {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)

        // Event
        event.title = party.title
        event.startDate = party.startDate
        event.endDate = party.endDate
        event.location = "\(party.address1) \(party.address2) \(party.address3)"
        event.URL = party.url
        event.notes = party.details

        // addController
        let addController = EKEventEditViewController()
        addController.eventStore = eventStore
        addController.event = event
        addController.editViewDelegate = self
        presentViewController(addController, animated: true, completion: nil)
    }

    // MARK: SFSafariViewControllerDelegate

    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: EKEventEditViewDelegate

    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        switch action {
        case .Saved:
            do {
                if let event = controller.event {
                    try controller.eventStore.saveEvent(event, span: .ThisEvent)
                }
            } catch { }
            break;
        default:
            break;
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
