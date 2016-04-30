//
//  AppDelegate.swift
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Sugar So Studio. All rights reserved.
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

        NSTimeZone.setDefaultTimeZone(NSTimeZone(name: "PST")!)

        // Global Tint Color (Xcode Bug #1)
        UIView.appearance().tintColor = UIColor(red: 106.0/255.0, green: 111.8/255.0, blue: 220.0/255.0, alpha: 1.0)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let master = storyboard.instantiateViewControllerWithIdentifier("master")
        let detail = storyboard.instantiateViewControllerWithIdentifier("noparty")

        let controller = UISplitViewController()
        controller.viewControllers = [master, detail]
        controller.preferredDisplayMode = .AllVisible
        controller.preferredPrimaryColumnWidthFraction = 0.45
        controller.delegate = self
        window?.rootViewController = controller

        return true
    }

    // MARK: UISplitViewControllerDelegate

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if secondaryViewController is UINavigationController {
            return false
        } else {
            return true
        }
    }

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        if let nvc = primaryViewController as? UINavigationController where nvc.topViewController is PartiesTableViewController {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("noparty")
        } else {
            return nil
        }
    }
}

