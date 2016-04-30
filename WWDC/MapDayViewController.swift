//
//  MapDayViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
//

import UIKit
import MapKit

class MapDayViewController: UIViewController, MKMapViewDelegate {
    var parties: [Party]!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        loadMap()
        mapView.delegate = self
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.camera.altitude *= 2
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loadMap()
    }

    func loadMap() {
        mapView.removeAnnotations(mapView.annotations)
        for (partyIndex, party) in parties.enumerate() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(party.latitude, party.longitude)
            annotation.title = party.title
            annotation.subtitle = party.hours
            annotation.partyIndex = partyIndex
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        var pinAnnotationView: MKPinAnnotationView?
        if annotation is MKPointAnnotation {
            pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("party") as? MKPinAnnotationView
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "party")
            }

            if let pointAnnotation = annotation as? MKPointAnnotation {
                let party = parties[pointAnnotation.partyIndex.integerValue]
                pinAnnotationView?.pinTintColor = party.isGoing ? UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0) : UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            }
            pinAnnotationView?.canShowCallout = true
            pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        return pinAnnotationView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("party", sender: view.annotation)
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PartyTableViewController, pointAnnotation = sender as? MKPointAnnotation where segue.identifier == "party" {
            vc.party = parties[pointAnnotation.partyIndex.integerValue]
        }
    }
}
