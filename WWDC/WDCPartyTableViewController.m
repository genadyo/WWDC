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

    // remove badge
    NSMutableArray *badgeMutableArray = [@[] mutableCopy];
    if (([SDCloudUserDefaults objectForKey:@"badge"] != nil) && ([[SDCloudUserDefaults objectForKey:@"badge"] isKindOfClass:[NSArray class]])) {
        badgeMutableArray = [[SDCloudUserDefaults objectForKey:@"badge"] mutableCopy];
    }
    if ([badgeMutableArray indexOfObject:self.party.objectId] == NSNotFound) {
        [badgeMutableArray addObject:self.party.objectId];
    }
    [SDCloudUserDefaults setObject:[badgeMutableArray copy] forKey:@"badge"];
    [SDCloudUserDefaults synchronize];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)refreshGoing
{
//    if (([SDCloudUserDefaults objectForKey:@"going"] == nil) || !([[SDCloudUserDefaults objectForKey:@"going"] isKindOfClass:[NSArray class]])) {
//        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f]] forState:UIControlStateNormal];
//        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f] forState:UIControlStateHighlighted];
//        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f]] forState:UIControlStateHighlighted];
//    } else if ([[SDCloudUserDefaults objectForKey:@"going"] indexOfObject:self.party.objectId] == NSNotFound) {
//        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f]] forState:UIControlStateNormal];
//        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f] forState:UIControlStateHighlighted];
//        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f]] forState:UIControlStateHighlighted];
//    } else {
//        [self.goingButton setTitleColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//        [self.goingButton setImage:[Assets imageOfGoingMarkWithInitColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:1.0f]] forState:UIControlStateNormal];
//        [self.goingButton setTitleColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:0.3f] forState:UIControlStateHighlighted];
//        [self.goingButton setImage:[Assets imageOfGoingMarkWithInitColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:0.3f]] forState:UIControlStateHighlighted];
//    }
}

- (IBAction)updateGoing:(id)sender
{
    NSMutableArray *goingMutableArray;
    if (([SDCloudUserDefaults objectForKey:@"going"] != nil) && ([[SDCloudUserDefaults objectForKey:@"going"] isKindOfClass:[NSArray class]])) {
        goingMutableArray = [[SDCloudUserDefaults objectForKey:@"going"] mutableCopy];
    } else {
        goingMutableArray = [@[] mutableCopy];
    }
    if ([goingMutableArray indexOfObject:self.party.objectId] == NSNotFound) {
        [goingMutableArray addObject:self.party.objectId];
    } else {
        [goingMutableArray removeObject:self.party.objectId];
    }
    [SDCloudUserDefaults setObject:[goingMutableArray copy] forKey:@"going"];
    [SDCloudUserDefaults synchronize];
    [self refreshGoing];
    [[WDCParties sharedInstance] saveGoing];

    if ([self.splitViewController.viewControllers[0] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = self.splitViewController.viewControllers[0];
        if ([navigationController.topViewController isKindOfClass:[WDCPartiesTVC class]]) {
            WDCPartiesTVC *partiesTVC = (WDCPartiesTVC *)navigationController.topViewController;
            [partiesTVC updateFilteredParties];
        }
    }
}

- (IBAction)openCal:(id)sender
{
    EKEventStore *es = [[EKEventStore alloc] init];
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    BOOL needsToRequestAccessToEventStore = (authorizationStatus == EKAuthorizationStatusNotDetermined);

    if (needsToRequestAccessToEventStore) {
        [es requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self addEvent];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please allow access to the Calendars", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    } else {
        BOOL granted = (authorizationStatus == EKAuthorizationStatusAuthorized);
        if (granted) {
            [self addEvent];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please allow access to the Calendars", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)addEvent
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];

    // Event
    event.title     = self.party.title;
    event.startDate = self.party.startDate;
    event.endDate   = self.party.endDate;
    event.location  = [NSString stringWithFormat:@"%@, %@, %@", self.party.address1, self.party.address2, self.party.address3];
    event.URL       = [NSURL URLWithString:self.party.url];
    event.notes     = self.party.details;

    // addController
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    addController.eventStore = eventStore;
    addController.event = event;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    NSError *error = nil;
    switch (action) {
        case EKEventEditViewActionSaved:
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
