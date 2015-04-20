//
//  WDCPartiesTVC.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "JVObserver.h"
#import "WDCPartiesTVC.h"
#import "WDCParty.h"
#import "WDCParties.h"
#import "WDCPartyTVC.h"
#import "WDCPartyTableViewController.h"
#import "WDCMapDayViewController.h"
#import "Parties-Swift.h"
#import "WDCAppDelegate.h"
@import CoreLocation;

@interface WDCPartiesTVC ()

@property (strong, nonatomic) NSArray *parties;
@property (strong, nonatomic) NSArray *filteredParties;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goingSegmentedControl;
@property (strong, nonatomic) NSMutableArray *observers;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) JVObserver *objectIdObserver;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@end

@implementation WDCPartiesTVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // hide back text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];

    // PaintCode
    [self.infoButton setImage:[Assets imageOfGear] forState:UIControlStateNormal];
    [self.goingSegmentedControl setImage:[Assets imageOfTogglegoingWithInitColor:[UIColor whiteColor]] forSegmentAtIndex:1];
    [self.goingSegmentedControl setImage:[Assets imageOfToggleallactive] forSegmentAtIndex:0];

    // Google
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WDCPartiesTVC"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    NSInteger selected = [[[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"] integerForKey:@"selected"];
    if (selected) {
        self.goingSegmentedControl.selectedSegmentIndex = selected;
    }

    self.tableView.tableFooterView = [[UIView alloc] init];

    self.observers = [[NSMutableArray alloc] init];
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    [self refresh:self];
}

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

    WDCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.objectIdObserver = [JVObserver observerForObject:appDelegate keyPath:@"partyObjectId" target:self block:^(__weak typeof(self) self) {
        if (!appDelegate.partyObjectId) {
            return;
        }

        NSString *partyObjectId = appDelegate.partyObjectId;
        appDelegate.partyObjectId = nil;
        for (NSArray *partiesArray in self.parties) {
            for (WDCParty *party in partiesArray) {
                if (party.show == YES && [party.objectId isEqualToString:partyObjectId]) {
                    [self performSegueWithIdentifier:@"party" sender:party];
                    return;
                }
            }
        }
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)refresh:(id)sender
{
    [[WDCParties sharedInstance] refreshWithBlock:^(BOOL succeeded, NSArray *parties) {
        if (succeeded) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (WDCParty *party in parties) {
                if (![dict objectForKey:[party sortDate]]) {
                    [dict setObject:[[NSMutableArray alloc] init] forKey:[party sortDate]];
                }
                [[dict objectForKey:[party sortDate]] addObject:party];
            }
            NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingComparator:^(NSString *str1, NSString *str2) {
                return [str1 compare:str2 options:NSNumericSearch];
            }];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *key in sortedKeys) {
                NSArray *sortDesc = @[
                                      [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)]
                                      ];
                [array addObject:[[dict objectForKey:key] sortedArrayUsingDescriptors:sortDesc]];
            }
            self.parties = [array copy];
            [self updateFilteredParties];
            if ([WDCParties sharedInstance].disableCache) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            [[Mixpanel sharedInstance] track:@"WDCParties" properties:@{@"refresh": @"FAILED"}];
        }
    }];
}

- (IBAction)updateSegment:(UISegmentedControl *)sender
{
    [self updateFilteredParties];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"];
    [userDefaults setInteger:sender.selectedSegmentIndex forKey:@"selected"];
    [userDefaults synchronize];
}

- (void)updateFilteredParties
{
    if (self.goingSegmentedControl.selectedSegmentIndex == 0) {
        self.filteredParties = self.parties;
        self.tableView.scrollEnabled = YES;
    } else {
        NSMutableArray *filteredPartiesMutable = [[NSMutableArray alloc] init];
        for (NSArray *array in self.parties) {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
            for (WDCParty *party in array) {
                if ([[WDCParties sharedInstance].going indexOfObject:party.objectId] != NSNotFound) {
                    [mutableArray addObject:party];
                }
            }
            if ([mutableArray count]) {
                [filteredPartiesMutable addObject:[mutableArray copy]];
            }
        }
        self.filteredParties = [filteredPartiesMutable copy];
        if ([self.filteredParties count] == 0) {
            self.tableView.scrollEnabled = NO;
        } else {
            self.tableView.scrollEnabled = YES;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.goingSegmentedControl.selectedSegmentIndex == 1 && self.filteredParties.count == 0) {
        return 1;
    } else {
        return self.filteredParties.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.goingSegmentedControl.selectedSegmentIndex == 1 && self.filteredParties.count == 0) {
        return 1;
    } else {
        return [self.filteredParties[section] count];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
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
        if ([[WDCParties sharedInstance].going indexOfObject:party.objectId] == NSNotFound) {
            partyCell.goingView.hidden = YES;
        } else {
            partyCell.goingView.hidden = NO;
        }
        
        partyCell.iconImageView.image = party.icon;
        if (!party.icon) {
            __weak typeof(party) weakParty = party;
            JVObserver *observer = [JVObserver observerForObject:party keyPath:@"icon" target:self block:^(__weak typeof(self) self) {
                if (weakParty.icon) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                };
            }];
            [self.observers addObject:observer];
        }

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    if (!(self.goingSegmentedControl.selectedSegmentIndex == 1 && self.filteredParties.count == 0)) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40.0f)];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40.0f)];
        bgView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        [view addSubview:bgView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, tableView.frame.size.width-22*2, 40.0f)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0f];
        label.text = [((WDCParty *)[self.filteredParties[section] lastObject]) date];
        label.textColor = [UIColor colorWithRed:117.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [view addSubview:label];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:CGRectMake(tableView.frame.size.width-40.0f, 0.0f, 20, 40.0f)];
        [button setImage:[Assets imageOfMapWithFrame:button.bounds] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
        button.tag = section;
        [view addSubview:button];
    }
    return view;
}

- (void)buttonClicked:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"map" sender:[NSNumber numberWithInteger:sender.tag]];
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
        UINavigationController *navigationController = segue.destinationViewController;
        WDCPartyTableViewController *destController = (WDCPartyTableViewController *)[navigationController topViewController];
        destController.party = party;
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
