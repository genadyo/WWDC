//
//  drawAssets.swift
//  SFParties
//
//  Created by Genady Okrain on 11/20/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

import UIKit

@IBDesignable class WDCAddToCalendar : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawAddToCalendar()
    }
}

@IBDesignable class WDCLocation : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawLocation()
    }
}

@objc @IBDesignable class WDCMapButton : UIButton {
    override func drawRect(rect: CGRect) {
        Assets.drawMap(frame: rect)
    }
}

@IBDesignable class WDCBlankstate : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawBlankstate()
    }
}

@IBDesignable class WDCGoing : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawGoing()
    }
}

@objc @IBDesignable class WDCGoingButton : UIButton {
    override func drawRect(rect: CGRect) {
        Assets.drawGoingButton(frame: rect)
    }
}

@objc @IBDesignable class WDCToggleSegmentedControl : UISegmentedControl {
    override func drawRect(rect: CGRect) {
//        println("selectedSegmentIndex: \(selectedSegmentIndex)")
        let colors = [self.tintColor, UIColor(red: 249/250, green: 249/250, blue: 249/250, alpha: 1.0)]
        Assets.drawToggleallactive(frame: rect, iconColor: colors[(selectedSegmentIndex+1)%2])
        Assets.drawTogglegoing(frame: rect, iconColor: colors[selectedSegmentIndex])
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // drawRect on change
        super.touchesEnded(touches, withEvent: event)
        setNeedsDisplay()
    }
}