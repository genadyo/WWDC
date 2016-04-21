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
    var dict = [Int: Int]()

    override func awakeWithContext(context: AnyObject!) {
        // Initialize variables here.
        super.awakeWithContext(context)

        // analytics
        let userDefaults = NSUserDefaults(suiteName: "group.so.sugar.SFParties")!
        userDefaults.setInteger(userDefaults.integerForKey("watchRuns")+1, forKey: "watchRuns")
        userDefaults.synchronize()

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
            // calculate type
            var rowTypes = ["section", "row"];
            var date = (parties[0] as! WDCParty).date
            for i in 1 ..< parties.count {
                if parties[i].date == date {
                    rowTypes += ["row"]
                } else {
                    rowTypes += ["section", "row"]
                    date = parties[i].date
                }
            }

            // set number of parties
            interfaceTable.setRowTypes(rowTypes)

            // set party rows
            var rowNum = 0
            date = parties[0].date
            for (idx, party) in parties.enumerate() {
                if parties[idx].date != date || idx == 0 {
                    let sectionRow = interfaceTable.rowControllerAtIndex(rowNum) as! WDCSectionTRC
                    sectionRow.sectionLabel.setText(parties[idx].date)
                    date = parties[idx].date
                    rowNum += 1
                }

                let wdcParty = party as! WDCParty
                let row = interfaceTable.rowControllerAtIndex(rowNum) as! WDCPartiesTRC
                dict[rowNum] = idx
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
                rowNum += 1
            }
        }
    }

    // MARK: Segues

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == "map" {
            if let idx = dict[rowIndex] {
                if let wdcParty = parties[idx] as? WDCParty {
                    return wdcParty
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }

        return nil
    }
}
