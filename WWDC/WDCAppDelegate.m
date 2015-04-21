//
//  WDCAppDelegate.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCAppDelegate.h"
#import "WDCParty.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GAI.h"
#import "WDCPartiesTVC.h"
#import "AAPLTraitOverrideViewController.h"
#import <Keys/SFPartiesKeys.h>
#import <Parse/Parse.h>

@interface WDCAppDelegate () <UISplitViewControllerDelegate>

@end


@implementation WDCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Keys
    SFPartiesKeys *keys = [[SFPartiesKeys alloc] init];
    
    // Push Notifications
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    // Parse
    [Parse setApplicationId:keys.parseApplicationId clientKey:keys.parseClientKey];

    // GAI
    [[GAI sharedInstance] trackerWithTrackingId:keys.googleAnalytics];

    // Mixpanel
    [Mixpanel sharedInstanceWithToken:keys.mixpanel];

    // Crashlytics
    [Fabric with:@[CrashlyticsKit]];

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

    // get icloud user id
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *userRecordID, NSError *error) {
        if (error) {
            [[Mixpanel sharedInstance] track:@"fetchUserRecord" properties:@{@"Status": @"Error"}];
        } else {
            if (userRecordID) {
                [[Mixpanel sharedInstance] identify:userRecordID.recordName];
            }
        }
    }];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *partiesDeeplinkPrefix = @"parties://party/";
    if ([url.absoluteString hasPrefix:partiesDeeplinkPrefix]) {
        self.partyObjectId = [url.absoluteString substringFromIndex:partiesDeeplinkPrefix.length];
        return YES;
    }

    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    NSString *objectId = userActivity.userInfo[@"objectId"];
    if (objectId != nil) {
        self.partyObjectId = objectId;
        return YES;
    }

    return NO;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
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
    if ([[(UINavigationController *)primaryViewController topViewController] isKindOfClass:[WDCPartiesTVC class]]) {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"noparty"];
        return vc;
    } else {
        return nil;
    }
}

@end
