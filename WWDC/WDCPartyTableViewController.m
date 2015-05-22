//
//  WDCPartyTableViewController.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

@import EventKitUI;
@import MapKit;
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "JVObserver.h"
#import "WDCPartyTableViewController.h"
#import "WDCParties.h"
#import "WDCPartiesTVC.h"
#import "WDCMapDayViewController.h"
#import "Parties-Swift.h"
#import <Keys/SFPartiesKeys.h>
#import <SDCloudUserDefaults/SDCloudUserDefaults.h>

@interface WDCPartyTableViewController () <EKEventEditViewDelegate>

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
@property (strong, nonatomic) JVObserver *observer;
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

    // Handoff
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"so.sugar.SFParties.view"];
    activity.title = self.party.title;
    activity.userInfo = @{@"objectId": self.party.objectId};
    activity.webpageURL = [NSURL URLWithString:self.party.url];
    self.userActivity = activity;
    [self.userActivity becomeCurrent];

    // Google
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WDCPartyTableViewController"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    self.observer = [JVObserver observerForObject:self.party keyPath:@"logo" target:self block:^(__weak typeof(self) self) {
        if (self.party.logo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.logoImageView.image = self.party.logo;
            });
        }
    }];

    self.titleLabel.text = self.party.title;

    NSMutableAttributedString *attributedDetails = [[NSMutableAttributedString alloc]initWithString:self.party.details];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    [attributedDetails addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.party.details.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;
    paragraphStyle.minimumLineHeight = 20.0f;
    [attributedDetails addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.party.details.length)];
    UIColor *color = [UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0f];
    [attributedDetails addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, self.party.details.length)];
    self.detailsLabel.attributedText = attributedDetails;
    self.dateLabel.text = [self.party date];
    self.hoursLabel.text = [self.party hours];
    MKCoordinateRegion region;
    region.center.latitude = [self.party.latitude floatValue];
    region.center.longitude = [self.party.longitude floatValue];
    region.span.latitudeDelta = 0.0075f;
    region.span.longitudeDelta = 0.0075f;
    [self.mapView setRegion:region animated:NO];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake([self.party.latitude floatValue], [self.party.longitude floatValue]);
    [self.mapView addAnnotation:annotation];
    self.address1Label.text = self.party.address1;
    self.address2Label.text = self.party.address2;
    self.address3Label.text = self.party.address3;
    [self refreshGoing];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 61.0;

    // UBER
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        UIImage *uber = [Assets imageOfUBER_API_Badge];
        [self.uberButton setImage:uber forState:UIControlStateNormal];
    }

    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SDCloudValueUpdatedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([[note userInfo] objectForKey:@"going"] != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshGoing];
                [[WDCParties sharedInstance] saveGoing];
            });
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
    [activity addUserInfoEntriesFromDictionary:@{@"objectId": self.party.objectId}];
    [super updateUserActivityState:activity];
}

- (void)refreshGoing
{
    if (([SDCloudUserDefaults objectForKey:@"going"] == nil) || !([[SDCloudUserDefaults objectForKey:@"going"] isKindOfClass:[NSArray class]])) {
        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f]] forState:UIControlStateNormal];
        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f] forState:UIControlStateHighlighted];
        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f]] forState:UIControlStateHighlighted];
    } else if ([[SDCloudUserDefaults objectForKey:@"going"] indexOfObject:self.party.objectId] == NSNotFound) {
        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:1.0f]] forState:UIControlStateNormal];
        [self.goingButton setTitleColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f] forState:UIControlStateHighlighted];
        [self.goingButton setImage:[Assets imageOfNotGoingMarkWithInitColor:[UIColor colorWithRed:106.0/255.0f green:118.0/255.f blue:220.f/255.0f alpha:0.3f]] forState:UIControlStateHighlighted];
    } else {
        [self.goingButton setTitleColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.goingButton setImage:[Assets imageOfGoingMarkWithInitColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:1.0f]] forState:UIControlStateNormal];
        [self.goingButton setTitleColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:0.3f] forState:UIControlStateHighlighted];
        [self.goingButton setImage:[Assets imageOfGoingMarkWithInitColor:[UIColor colorWithRed:46.0f/255.0f green:204.0/255.f blue:113.f/255.0f alpha:0.3f]] forState:UIControlStateHighlighted];
    }
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
        [[Mixpanel sharedInstance].people increment:@"updateGoing.Going" by:@1];
    } else {
        [goingMutableArray removeObject:self.party.objectId];
        [[Mixpanel sharedInstance].people increment:@"updateGoing.NotGoing" by:@1];
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

- (IBAction)openMaps:(id)sender
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.party.latitude floatValue];
    coordinate.longitude = [self.party.longitude floatValue];
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    [addressDictionary setObject:@"United States" forKey:(NSString *)kABPersonAddressCountryKey];
    if (self.party.address2) {
        [addressDictionary setObject:self.party.address2 forKey:(NSString *)kABPersonAddressStreetKey];
    }
    NSArray *address3Split = [self.party.address3 componentsSeparatedByString: @", "];
    if ([address3Split count] == 2) {
        [addressDictionary setObject:address3Split[0] forKey:(NSString *)kABPersonAddressCityKey];
        NSArray *address3SplitSplit = [address3Split[1] componentsSeparatedByString: @" "];
        if ([address3SplitSplit count] == 2) {
            [addressDictionary setObject:address3SplitSplit[0] forKey:(NSString *)kABPersonAddressStateKey];
            [addressDictionary setObject:address3SplitSplit[1] forKey:(NSString *)kABPersonAddressZIPKey];
        }
    }
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:[addressDictionary copy]]];
    item.name = self.party.title;
    [item openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
                                        MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard]}];
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

- (IBAction)openUber:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        // Keys
        SFPartiesKeys *keys = [[SFPartiesKeys alloc] init];

        // urls
        NSString *uber = [NSString stringWithFormat:@"uber://?client_id=%@&action=setPickup&pickup=my_location&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@&dropoff[formatted_address]=%@%%20%@",
                          keys.uber,
                          [self.party.latitude floatValue],
                          [self.party.longitude floatValue],
                          [self.party.address1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [self.party.address2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [self.party.address3 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        NSString *url = [NSString stringWithFormat:@"https://m.uber.com/sign-up?client_id=%@&dropoff_latitude=%f&dropoff_longitude=%f&dropoff_nickname=%@&dropoff_address=%@%%20%@",
                         keys.uber,
                         [self.party.latitude floatValue],
                         [self.party.longitude floatValue],
                         [self.party.address1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [self.party.address2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [self.party.address3 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        // open Uber or Safari
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:uber]]) {
            [[Mixpanel sharedInstance] track:@"openUber" properties:@{@"Status": @"OK", @"Party": self.party.title}];
            [[Mixpanel sharedInstance].people increment:@"openUber.OK" by:@1];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uber]];
        } else {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
                [[Mixpanel sharedInstance] track:@"openUber" properties:@{@"Status": @"Web", @"Party": self.party.title}];
                [[Mixpanel sharedInstance].people increment:@"openUber.Web" by:@1];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please allow access to Safari", nil)
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
                [[Mixpanel sharedInstance] track:@"openUber" properties:@{@"Status": @"Error", @"Party": self.party.title}];
            }
        }
    } else {
        [self openMaps:sender];
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 6) { // Xcode Bug #2
        cell.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:111.8f/255.0f blue:220.0f/255.0f alpha:1.0f];
    }
    return cell;
}

// This is needed because of the static table cells or because its a bug!
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"web"]) {
        WDCPartyWebViewController *destController = (WDCPartyWebViewController *)[segue destinationViewController];
        destController.title = self.party.title;
        destController.url = [NSURL URLWithString:self.party.url];
    }
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
