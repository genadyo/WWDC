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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Keys
        let keys = SFPartiesKeys()

        // Push Notifications
//        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//        application.registerUserNotificationSettings(settings)
//        application.registerForRemoteNotifications()

        // One Signal
//        oneSignal =  OneSignal(launchOptions: launchOptions, appId: keys.oneSignal(), handleNotification: nil)

        // Crashlytics
        Fabric.with([Crashlytics.start(withAPIKey: keys.crashlytics)])

        // Default time
//        NSTimeZone.setDefaultTimeZone(NSTimeZone(identifier: "PST")!)

        // Global Tint Color (Xcode Bug #1)
        UIView.appearance().tintColor = UIColor(red: 106.0/255.0, green: 118.0/255.0, blue: 220.0/255.0, alpha: 1.0)

        // Delegate
        if let splitViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UISplitViewController {
            splitViewController.delegate = self
            splitViewController.preferredDisplayMode = .allVisible
            window?.rootViewController = splitViewController
            window?.makeKeyAndVisible()
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return true
    }

    // MARK: UISplitViewControllerDelegate

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if secondaryViewController.isKind(of: UINavigationController.self) {
            return false
        } else {
            return true
        }
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if primaryViewController.isKind(of: UINavigationController.self) {
            let nvc = primaryViewController as! UINavigationController
            if nvc.topViewController is PartiesTableViewController {
                return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noparty")
            }
        }

        return nil
    }
}

