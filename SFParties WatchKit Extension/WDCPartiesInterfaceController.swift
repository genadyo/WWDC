//
//  WDCPartiesInterfaceController.swift
//  SFParties WatchKit Extension
//
//  Created by Genady Okrain on 11/21/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

import WatchKit

class WDCPartiesInterfaceController: WKInterfaceController {
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    var parties :NSArray!

    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
        
        // Configure interface objects here.
        // NSLog("%@ init", self)

        // load my table
        loadTableData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        // NSLog("%@ will activate", self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        // NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }

    func loadTableData() {
        // read the cached parties
        parties = WDCParties.sharedInstance().filteredParties

        if (parties.count == 0) {
            self.interfaceTable.setNumberOfRows(1, withRowType: "empty")
        } else {
            // set number of parties
            self.interfaceTable.setNumberOfRows(parties.count, withRowType: "row")

            // set party rows
            for (idx, party) in enumerate(parties) {
                let wdcParty = party as WDCParty
                let row = self.interfaceTable.rowControllerAtIndex(idx) as WDCPartiesTRC
                row.titleInterfaceLabel.setText(wdcParty.title)
                // cache the icon image on the watch
                WKInterfaceDevice().addCachedImage(wdcParty.watchIcon, name: wdcParty.objectId)
                row.iconInterfaceImage.setImageNamed(wdcParty.objectId)
            }
        }
    }

    // MARK: Segues

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == "map" {
            return parties[rowIndex]
        }

        return nil
    }
}
