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
    var parties: NSArray!
    var wormhole: MMWormhole?

    override func awakeWithContext(context: AnyObject!) {
        // Initialize variables here.
        super.awakeWithContext(context)

        // load my table
        loadTableData()

        wormhole = MMWormhole(applicationGroupIdentifier: "group.so.sugar.SFParties", optionalDirectory: "wormhole")
        wormhole!.listenForMessageWithIdentifier("loadTableData") { [weak self] _ in
            self?.loadTableData()
        }
    }

    override func willActivate() {
        super.willActivate()

        loadTableData()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    func loadTableData() {
        // read the cached parties
        parties = WDCParties.sharedInstance().watchParties

        if (parties.count == 0) {
            interfaceTable.setNumberOfRows(1, withRowType: "empty")
        } else {
            // set number of parties
            interfaceTable.setNumberOfRows(parties.count, withRowType: "row")

            // set party rows
            for (idx, party) in enumerate(parties) {
                let wdcParty = party as! WDCParty
                let row = interfaceTable.rowControllerAtIndex(idx) as! WDCPartiesTRC
                row.titleLabel.setText(wdcParty.title)
                // cache the icon image on the watch
                if WKInterfaceDevice().cachedImages[wdcParty.objectId] != nil {
                    row.iconImage.setImageNamed(wdcParty.objectId)
                } else if wdcParty.watchIcon != nil {
                    if WKInterfaceDevice().addCachedImage(wdcParty.watchIcon, name: wdcParty.objectId) {
                        row.iconImage.setImageNamed(wdcParty.objectId)
                    } else {
                        row.iconImage.setImage(wdcParty.watchIcon)
                    }
                }
            }
        }
    }

    // MARK: Segues

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == "map" {
            let wdcParty = parties[rowIndex] as! WDCParty
            return wdcParty
        }

        return nil
    }
}
