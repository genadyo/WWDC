//
//  WDCPartiesInterfaceController.swift
//  SFParties WatchKit Extension
//
//  Created by Genady Okrain on 11/21/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

import UIKit
import WatchKit

class WDCPartiesInterfaceController: WKInterfaceController {
    @IBOutlet weak var interfaceTable: WKInterfaceTable!

    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
        
        // Configure interface objects here.
        NSLog("%@ init", self)

        // load my table
        loadTableData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }

    func loadTableData() {
        WDCParties.sharedInstance().refreshWithBlock { (succeeded, parties) -> Void in
            if (succeeded) {
                // TBD: order and stuff

                // set number of parties
                self.interfaceTable.setNumberOfRows(parties.count, withRowType: "row")

                // set party rows
                for (idx, party) in enumerate(parties) {
                    let wdcParty = party as WDCParty
                    let row = self.interfaceTable.rowControllerAtIndex(idx) as WDCPartiesTRC
                    row.titleInterfaceLabel.setText(wdcParty.title)
                    row.iconInterfaceImage.setImage(wdcParty.icon)
                }
            }
        }
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {

    }
}
