//
//  WDCPartyInterfaceController.swift
//  SFParties WatchKit Extension
//
//  Created by Genady Okrain on 11/22/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

import WatchKit

class WDCPartyInterfaceController: WKInterfaceController {
    @IBOutlet weak var map: WKInterfaceMap!
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    @IBOutlet weak var addressLabel: WKInterfaceLabel!
    var party: WDCParty!
    
    override func awakeWithContext(context: AnyObject!) {
        // party
        precondition(context is WDCParty, "Expected class of `context` to be WDCParty.")
        party = context as WDCParty

        // Initialize variables here.
        super.awakeWithContext(context)

        // Set the title of the interface controller based on the party name.
        setTitle(party.title)

        // setup interface
        dateLabel.setText(party.shortDate)
        addressLabel.setText(party.address1 + ", " + party.address2)
        map.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.78417, -122.40156), MKCoordinateSpanMake(0.025, 0.025)))
        map.addAnnotation(CLLocationCoordinate2DMake(party.latitude.doubleValue, party.longitude.doubleValue), withPinColor: .Green)

        // Configure interface objects here.
        // NSLog("%@ init", self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        // NSLog("%@ will activate", self)

        // Google
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: "WDCPartyInterfaceController")
//        tracker.send(GAIDictionaryBuilder.createAppView().build())
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        // NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
}
