//
//  WDCPartyTableViewController.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

@import EventKitUI;
@import MapKit;
@import SafariServices;
@import Keys;
#import "WDCPartyTableViewController.h"
#import "WDCParties.h"
#import "WDCPartiesTVC.h"
#import "WDCMapDayViewController.h"
#import "Parties-Swift.h"
#import <SDCloudUserDefaults/SDCloudUserDefaults.h>

@interface WDCPartyTableViewController () <EKEventEditViewDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *address1Label;
@property (weak, nonatomic) IBOutlet UILabel *address2Label;
@property (weak, nonatomic) IBOutlet UILabel *address3Label;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *titleCell;
@property (weak, nonatomic) IBOutlet UIButton *uberButton;

@end

@implementation WDCPartyTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // refresh for iPad
    if ([self.splitViewController.viewControllers[0] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = self.splitViewController.viewControllers[0];
        if ([navigationController.topViewController isKindOfClass:[WDCPartiesTVC class]]) {
            WDCPartiesTVC *partiesTVC = (WDCPartiesTVC *)navigationController.topViewController;
            [partiesTVC updateFilteredParties];
        }
    }

    // hide back text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];

    // UBER
//    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
//        UIImage *uber = [Assets imageOfLyft];
//        [self.uberButton setImage:uber forState:UIControlStateNormal];
//    }
}

@end
