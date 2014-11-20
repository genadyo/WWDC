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
//    override func drawRect(rect: CGRect) {
//        Assets.drawMap(frame: rect)
//    }
}

@IBDesignable class WDCBlankstate : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawBlankstate()
    }
}

@IBDesignable class WDCGoing : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawGoing(frame: rect)
    }
}

@objc @IBDesignable class WDCGoingButton : UIButton {
//    override func drawRect(rect: CGRect) {
//        Assets.drawGoing(frame: rect)
//    }
}

@objc @IBDesignable class WDCToggleSegmentedControl : UISegmentedControl {
//    override func drawRect(rect: CGRect) {
//        for (var i = 0; i < self.subviews.count; i++) {
//            if ((self.subviews[i].isSelected) != nil) {
//                Assets.drawToggleallactive(frame: rect)
//            } else {
//                Assets.drawTogglegoing(frame: rect)
//            }
//        }
//    }
}