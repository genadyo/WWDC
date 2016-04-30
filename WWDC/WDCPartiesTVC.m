//
//  WDCPartiesTVC.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCPartiesTVC.h"
//#import "WDCParty.h"
#import "WDCParties.h"
#import "WDCPartyTVC.h"
//#import "WDCPartyTableViewController.h"
#import "WDCMapDayViewController.h"
#import "Parties-Swift.h"
#import "WDCAppDelegate.h"
//#import <SDCloudUserDefaults/SDCloudUserDefaults.h>
@import CoreLocation;

@interface WDCPartiesTVC ()

@property (strong, nonatomic) NSArray *parties;
@property (strong, nonatomic) NSArray *filteredParties;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goingSegmentedControl;
@property (strong, nonatomic) NSMutableArray *observers;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@end

@implementation WDCPartiesTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self updateFilteredParties];

    // ask for location once
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"party"]) {
        WDCParty *party;
        if ([sender isKindOfClass:[WDCParty class]]) {
            party = (WDCParty *)sender;
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            party = (self.filteredParties[indexPath.section])[indexPath.row];
        }
//        UINavigationController *navigationController = segue.destinationViewController;
//        WDCPartyTableViewController *destController = (WDCPartyTableViewController *)[navigationController topViewController];
//        destController.party = party;
    } else if ([segue.identifier isEqualToString:@"map"]) {
        if ([sender isKindOfClass:[NSNumber class]]) {
            NSInteger tag = [(NSNumber *)sender integerValue];
            UINavigationController *navigationController = segue.destinationViewController;
            WDCMapDayViewController *destController = (WDCMapDayViewController *)[navigationController topViewController];
            destController.parties = self.filteredParties[tag];
        }
    }
}

@end
