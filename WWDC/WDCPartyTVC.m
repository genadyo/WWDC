//
//  WDCPartyTVC.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCPartyTVC.h"

@implementation WDCPartyTVC

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.bounds.size.width;
    [super layoutSubviews];
}

@end
