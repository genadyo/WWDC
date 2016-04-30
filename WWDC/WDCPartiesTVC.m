//
//  WDCPartiesTVC.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCPartiesTVC.h"
#import "WDCParty.h"
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];

    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        height = 90;
    }

    if (self.goingSegmentedControl.selectedSegmentIndex == 1 && self.filteredParties.count == 0) {
        height = [[UIScreen mainScreen] bounds].size.height-2*(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height);
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (self.goingSegmentedControl.selectedSegmentIndex == 1 && self.filteredParties.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"empty" forIndexPath:indexPath];
    } else {
        WDCPartyTVC *partyCell = [tableView dequeueReusableCellWithIdentifier:@"party" forIndexPath:indexPath];
        WDCParty *party = (self.filteredParties[indexPath.section])[indexPath.row];
        partyCell.titleLabel.text = party.title;
        partyCell.hoursLabel.text = [party hours];
//        partyCell.goingView.hidden = YES;
//        if ([SDCloudUserDefaults objectForKey:@"going"] != nil) {
//            if ([[SDCloudUserDefaults objectForKey:@"going"] isKindOfClass:[NSArray class]]) {
//                if ([[SDCloudUserDefaults objectForKey:@"going"] indexOfObject:party.objectId] != NSNotFound) {
//                    partyCell.goingView.hidden = NO;
//                }
//            }
//        }

//        partyCell.badgeView.hidden = YES;
//        if (partyCell.goingView.hidden == YES) {
//            partyCell.badgeView.hidden = NO;
//            if ([SDCloudUserDefaults objectForKey:@"badge"] != nil) {
//                if ([[SDCloudUserDefaults objectForKey:@"badge"] isKindOfClass:[NSArray class]]) {
//                    if ([[SDCloudUserDefaults objectForKey:@"badge"] indexOfObject:party.objectId] != NSNotFound) {
//                        partyCell.badgeView.hidden = YES;
//                    }
//                }
//            }
//        }

        [partyCell.seperator removeFromSuperview];
        if (indexPath.row != [self.filteredParties[indexPath.section] count]-1) {
            partyCell.seperator = [[UIView alloc] initWithFrame:CGRectMake(7, partyCell.frame.size.height-1, partyCell.frame.size.width-7*2, 1)];
            partyCell.seperator.opaque = YES;
            partyCell.seperator.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
            [partyCell addSubview:partyCell.seperator];
        } else {
            partyCell.seperator = [[UIView alloc] initWithFrame:CGRectMake(7, partyCell.frame.size.height-1, partyCell.frame.size.width-7*2, 1.0f)];
            partyCell.seperator.opaque = YES;
            partyCell.seperator.backgroundColor = [UIColor whiteColor];
            [partyCell addSubview:partyCell.seperator];
        }
        cell = partyCell;
    }

    return cell;
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
