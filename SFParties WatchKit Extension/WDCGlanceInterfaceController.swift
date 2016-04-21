//
//  WDCGlanceInterfaceController.swift
//  SFParties
//
//  Created by Genady Okrain on 3/5/15.
//  Copyright (c) 2015 Sugar So Studio. All rights reserved.
//

import WatchKit

class WDCGlanceInterfaceController: WKInterfaceController {
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var emptyLabel: WKInterfaceLabel!
    @IBOutlet weak var iconImage: WKInterfaceImage!
    @IBOutlet weak var timer: WKInterfaceTimer!
    var refreshTimer:NSTimer?

    override func awakeWithContext(context: AnyObject!) {
        // Initialize variables here.
        super.awakeWithContext(context)

        // analytics
        let userDefaults = NSUserDefaults(suiteName: "group.so.sugar.SFParties")!
        userDefaults.setInteger(userDefaults.integerForKey("glanceRuns")+1, forKey: "glanceRuns")
        userDefaults.synchronize()

        loadData()
    }

    func loadData() {
        let parties = WDCParties.sharedInstance().glanceParties

        if (parties.count == 0) {
            iconImage.setHidden(true)
            titleLabel.setHidden(true)
            timer.setHidden(true)
            emptyLabel.setHidden(false)
        } else {
            iconImage.setHidden(false)
            titleLabel.setHidden(false)
            timer.setHidden(false)
            emptyLabel.setHidden(true)
            let party = parties[0] as! WDCParty // TBD
            if WKInterfaceDevice().cachedImages[party.objectId] != nil {
                iconImage.setImageNamed(party.objectId)
            } else if party.watchIcon != nil {
                if WKInterfaceDevice().addCachedImage(party.watchIcon, name: party.objectId) {
                    iconImage.setImageNamed(party.objectId)
                } else {
                    iconImage.setImage(party.watchIcon)
                }
            }
            titleLabel.setText(party.title)
            timer.setDate(party.startDate)
            timer.start()

            // Handoff
            updateUserActivity("so.sugar.SFParties.view", userInfo: ["objectId": party.objectId], webpageURL: NSURL(string: party.url))
        }
    }

    override func willActivate() {
        super.willActivate()

        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(WDCGlanceInterfaceController.loadData), userInfo: nil, repeats: true)
    }

    override func didDeactivate() {
        super.didDeactivate()

        refreshTimer?.invalidate()
    }
}
