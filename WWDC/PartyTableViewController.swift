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
            logoImageView.pin_setImage(from: party.logo)
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = party.title
        }
    }

    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            let font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightLight)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Going/Old
        goingButton.isSelected = party.isGoing
        party.isOld = true
        delegate?.reloadData()

        // Self sizing cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.row == 6 { // Xcode Bug #2
            cell.backgroundColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    @IBAction func updateGoing(_ sender: UIButton) {
        party.isGoing = !party.isGoing
        goingButton.isSelected = party.isGoing
        delegate?.reloadData()
    }

    @IBAction func openMaps(_ sender: AnyObject) {
        let coordinate = CLLocationCoordinate2DMake(party.latitude, party.longitude)

        var addressDictionary = [String: AnyObject]()
        addressDictionary[CNPostalAddressCountryKey] = "United States" as AnyObject
        addressDictionary[CNPostalAddressStreetKey] = party.address2 as AnyObject
        let address3Split = party.address3.components(separatedBy: ", ")
        if address3Split.count == 2 {
            addressDictionary[CNPostalAddressCityKey] = address3Split[0] as AnyObject
            let address3SplitSplit = address3Split[1].components(separatedBy: " ")
            if address3SplitSplit.count == 2 {
                addressDictionary[CNPostalAddressStateKey] = address3SplitSplit[0] as AnyObject
                addressDictionary[CNPostalAddressPostalCodeKey] = address3SplitSplit[1] as AnyObject
            }
        }

        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary))
        item.name = party.title
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking, MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue])
    }

    @IBAction func openWeb(_ sender: AnyObject) {
        let safariViewController = SFSafariViewController(url: party.url)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction func openCal(_ sender: UITapGestureRecognizer) {
        let eventStore = EKEventStore()
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        let needsToRequestAccessToEventStore = authorizationStatus == .notDetermined

        if needsToRequestAccessToEventStore == true {
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                if granted == true {
                    self?.addEvent()
                } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            let granted = authorizationStatus == .authorized
            if granted == true {
                addEvent()
            } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    fileprivate func addEvent() {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)

        // Event
        event.title = party.title
        event.startDate = party.startDate
        event.endDate = party.endDate
        event.location = "\(party.address1) \(party.address2) \(party.address3)"
        event.url = party.url
        event.notes = party.details

        // addController
        let addController = EKEventEditViewController()
        addController.eventStore = eventStore
        addController.event = event
        addController.editViewDelegate = self
        present(addController, animated: true, completion: nil)
    }

    // MARK: SFSafariViewControllerDelegate

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: EKEventEditViewDelegate

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            do {
                if let event = controller.event {
                    try controller.eventStore.save(event, span: .thisEvent)
                }
            } catch { }
            break;
        default:
            break;
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
