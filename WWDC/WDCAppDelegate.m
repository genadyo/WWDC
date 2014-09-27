//
//  WDCAppDelegate.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCAppDelegate.h"
#import "WDCParty.h"
#import <Crashlytics/Crashlytics.h>
#import <Rollout/Rollout.h>
#import "GAI.h"
#import "WDCPartiesTVC.h"
#import "AAPLTraitOverrideViewController.h"
//#import <FBTweakShakeWindow.h>
//#import <Parse/Parse.h>

@interface WDCAppDelegate () <UISplitViewControllerDelegate>

@end


@implementation WDCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configuration
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    // Push Notifications
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
//    [Parse setApplicationId:configuration[@"PARSE_API"] clientKey:configuration[@"PARSE_KEY"]];

    // GAI
    [[GAI sharedInstance] trackerWithTrackingId:configuration[@"GOOGLE_ANALYTICS_API"]];

#if defined( DEBUG )
    [Rollout setup:configuration[@"ROLLOUT_API"] debug:YES];
#else
    [Rollout setup:configuration[@"ROLLOUT_API"] debug:NO];
#endif

    // Crashlytics
    [Crashlytics startWithAPIKey:configuration[@"CRASHLYTICS_API"]];

    // Global Tint Color (Xcode Bug #1)
    [[UIView appearance] setTintColor:[UIColor colorWithRed:106.0f/255.0f green:111.8f/255.0f blue:220.0f/255.0f alpha:1.0f]];

    // Facebook Tweaks
//    FBTweak *tweak = [[FBTweak alloc] initWithIdentifier:@"so.sugar.SFParties.copyParseToCloudKit"];
//    tweak.name = @"GO";
//    tweak.defaultValue = @NO;
//    FBTweakStore *store = [FBTweakStore sharedInstance];
//    FBTweakCategory *category = [[FBTweakCategory alloc] initWithName:@"CloudKit"];
//    [store addTweakCategory:category];
//    FBTweakCollection *collection = [[FBTweakCollection alloc] initWithName:@"Copy Parse To CloudKit"];
//    [category addTweakCollection:collection];
//    [collection addTweak:tweak];
//    [tweak addObserver:self];

    // Split View Controller
//#ifdef DEBUG
//    self.window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//#else
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//#endif

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

    [self.window makeKeyAndVisible];

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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"start > %@", [NSDate date]];
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"Notification" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *notification = [[CKNotificationInfo alloc] init];
    notification.alertLocalizationKey = @"%@";
    notification.alertLocalizationArgs = @[@"message"];
    subscription.notificationInfo = notification;
    [publicDatabase saveSubscription:subscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
//            NSLog(@"Subscription: %@", subscription);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
}

//- (void)tweakDidChange:(FBTweak *)tweak
//{
//    if ([tweak.currentValue boolValue]) {
//        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
//        PFQuery *query = [PFQuery queryWithClassName:@"WDCParty"];
//        NSArray *objects = [query findObjects];
//        NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
//        for (PFObject *party in objects) {
//            CKRecord *ckParty = [[CKRecord alloc] initWithRecordType:@"Party"];
//            ckParty[@"title"] = party[@"title"];
//            ckParty[@"address1"] = party[@"address1"];
//            ckParty[@"address2"] = party[@"address2"];
//            ckParty[@"address3"] = party[@"address3"];
//            ckParty[@"details"] = party[@"details"];
//            ckParty[@"startDate"] = party[@"startDate"];
//            ckParty[@"endDate"] = party[@"endDate"];
//            NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
//            NSString *iconFilename = [NSString stringWithFormat:@"icon.%d.jpg", arc4random() % 9999999];
//            NSString *logoFilename = [NSString stringWithFormat:@"logo.%d.jpg", arc4random() % 9999999];
//            NSURL *iconURL = [documentsURL URLByAppendingPathComponent:iconFilename];
//            NSURL *logoURL = [documentsURL URLByAppendingPathComponent:logoFilename];
//            [[party[@"icon"] getData] writeToURL:iconURL atomically:YES];
//            [[party[@"logo"] getData] writeToURL:logoURL atomically:YES];
//            ckParty[@"icon"] = [[CKAsset alloc] initWithFileURL:iconURL];
//            ckParty[@"logo"] = [[CKAsset alloc] initWithFileURL:logoURL];
//            ckParty[@"location"] = [[CLLocation alloc] initWithLatitude:[party[@"latitude"] floatValue] longitude:[party[@"longitude"] floatValue]];
//            ckParty[@"show"] = [NSNumber numberWithBool:party[@"show"]];
//            ckParty[@"url"] = party[@"url"];
//            [publicDatabase saveRecord:ckParty completionHandler:^(CKRecord *record, NSError *error) {
//                if (error) {
//                    NSLog(@"%@", error.localizedDescription);
//                }
//            }];
//        }
//    }
//}

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
