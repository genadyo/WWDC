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
#import "GAI.h"

@implementation WDCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configuration
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    // Push Notifications
    [application registerForRemoteNotifications];
    [Parse setApplicationId:configuration[@"PARSE_API"] clientKey:configuration[@"PARSE_KEY"]];

    // GAI
    [[GAI sharedInstance] trackerWithTrackingId:configuration[@"GOOGLE_ANALYTICS_API"]];

    // Crashlytics
    [Crashlytics startWithAPIKey:configuration[@"CRASHLYTICS_API"]];

    // Global Tint Color
    [[UIView appearance] setTintColor:[UIColor colorWithRed:106.0f/255.0f green:111.8f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    
    // Override point for customization after application launch.
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
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setDeviceTokenFromData:deviceToken];
    [installation saveInBackground];

    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"start > %@", [NSDate date]];
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"Notification" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *notification = [[CKNotificationInfo alloc] init];
    notification.desiredKeys = @[@"message"];
    subscription.notificationInfo = notification;
    [publicDatabase saveSubscription:subscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            NSLog(@"Subscription: %@", subscription);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];

    [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
}
}

@end
