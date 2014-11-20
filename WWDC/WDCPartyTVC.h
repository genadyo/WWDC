//
//  WDCPartyTVC.h
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFParties-Swift.h"

@interface WDCPartyTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet WDCGoing *goingView;
@property (strong, nonatomic) UIView *seperator;

@end
