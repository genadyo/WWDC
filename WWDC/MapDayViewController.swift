//
//  MapDayViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import MapKit

class MapDayViewController: UIViewController, MKMapViewDelegate {
    var parties: [Party]!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        loadMap()
        mapView.delegate = self
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.camera.altitude *= 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMap()
    }

    fileprivate func loadMap() {
        mapView.removeAnnotations(mapView.annotations)
        for (partyIndex, party) in parties.enumerated() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(party.latitude, party.longitude)
            annotation.title = party.title
            annotation.subtitle = party.hours
            annotation.partyIndex = partyIndex as NSNumber
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        var pinAnnotationView: MKPinAnnotationView?
        if annotation is MKPointAnnotation {
            pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "party") as? MKPinAnnotationView
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "party")
            }

            if let pointAnnotation = annotation as? MKPointAnnotation {
                let party = parties[pointAnnotation.partyIndex.intValue]
                pinAnnotationView?.pinTintColor = party.isGoing ? UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0) : UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            }
            pinAnnotationView?.canShowCallout = true
            pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return pinAnnotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "party", sender: view.annotation)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PartyTableViewController, let pointAnnotation = sender as? MKPointAnnotation, segue.identifier == "party" {
            vc.party = parties[pointAnnotation.partyIndex.intValue]
        }
    }
}
