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

@IBDesignable class WDCBlankstate : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawBlankstate()
    }
}

@IBDesignable class WDCGoing : UIView {
    override func drawRect(rect: CGRect) {
        Assets.drawTogglegoing(initColor: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1))
    }
}