//
//  AppDelegate.swift
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    var oneSignal: OneSignal?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Keys
        let keys = SfpartiesKeys()

        // Push Notifications
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        // One Signal
        oneSignal =  OneSignal(launchOptions: launchOptions, appId: keys.oneSignal(), handleNotification: nil)

        // Crashlytics
        Fabric.with([Crashlytics.startWithAPIKey(keys.crashlytics())])

        // Default time
        NSTimeZone.setDefaultTimeZone(NSTimeZone(name: "PST")!)

        // Global Tint Color (Xcode Bug #1)
        UIView.appearance().tintColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)

        // Delegate
        if let splitViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UISplitViewController {
            splitViewController.delegate = self
            splitViewController.preferredDisplayMode = .AllVisible
            window?.rootViewController = splitViewController
            window?.makeKeyAndVisible()
        }

        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return LyftManager.sharedInstance.openURL(url)
    }

    // MARK: UISplitViewControllerDelegate

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if secondaryViewController.isKindOfClass(UINavigationController) {
            return false
        } else {
            return true
        }
    }

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        if primaryViewController.isKindOfClass(UINavigationController) {
            let nvc = primaryViewController as! UINavigationController
            if nvc.topViewController is PartiesTableViewController {
                return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("noparty")
            }
        }

        return nil
    }
}

