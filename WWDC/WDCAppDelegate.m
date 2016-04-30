//
//  WDCAppDelegate.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

@import Fabric;
@import Crashlytics;
@import Keys;
@import CoreSpotlight;
#import <OneSignal/OneSignal.h>
#import "WDCAppDelegate.h"
#import "AAPLTraitOverrideViewController.h"
#import "Parties-Swift.h"

@interface WDCAppDelegate () <UISplitViewControllerDelegate>
@property (strong, nonatomic) OneSignal *oneSignal;
@end


@implementation WDCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Keys
    SfpartiesKeys *keys = [[SfpartiesKeys alloc] init];
    
    // Push Notifications
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    // One Signal
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions appId:keys.oneSignal handleNotification:nil];

    // Crashlytics
    [Fabric with:@[[Crashlytics startWithAPIKey:keys.crashlytics]]];

    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];

    // Global Tint Color (Xcode Bug #1)
    [[UIView appearance] setTintColor:[UIColor colorWithRed:106.0f/255.0f green:111.8f/255.0f blue:220.0f/255.0f alpha:1.0f]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *master = [storyboard instantiateViewControllerWithIdentifier:@"master"];
    UIViewController *detail = [storyboard instantiateViewControllerWithIdentifier: @"noparty"];

    UISplitViewController *controller = [[UISplitViewController alloc] init];
    controller.viewControllers = @[master, detail];
    controller.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    controller.preferredPrimaryColumnWidthFraction = 0.45f;
    controller.delegate = self;

    AAPLTraitOverrideViewController *traitController = [[AAPLTraitOverrideViewController alloc] init];
    traitController.viewController = controller;
    self.window.rootViewController = traitController;

    return YES;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([[(UINavigationController *)primaryViewController topViewController] isKindOfClass:[PartiesTableViewController class]]) {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"noparty"];
        return vc;
    } else {
        return nil;
    }
}

@end
