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

        navigationItem.title = parties[0].date

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
}
