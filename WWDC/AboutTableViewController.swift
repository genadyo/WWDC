//
//  AboutTableViewController.swift
//  Strobe
//
//  Created by Genady Okrain on 3/24/15.
//  Copyright (c) 2015 Genady Okrain. All rights reserved.
//

import UIKit
import MessageUI

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func share(sender: AnyObject) {
        let url = NSURL(string: "https://appsto.re/us/InPC0.i")!
        let string = NSLocalizedString("Parties for WWDC", comment: "")
        let activityViewController = UIActivityViewController(activityItems: [string, url], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            Mixpanel.sharedInstance().track("About->Share", properties: ["\(activityType)" : "\(completed)"])
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }

    // MARK: UITableViewControllerDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        var url:NSURL!

        if indexPath.section == 0 {

            if indexPath.item == 0 {
                Mixpanel.sharedInstance().track("Rate")

                let url = NSURL(string: "itms-apps://itunes.apple.com/app/id879924066")!

                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .Alert)
                    let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(ok)
                    presentViewController(alert, animated: true, completion: nil)
                }
            } else if indexPath.item == 1 {
                Mixpanel.sharedInstance().track("Twitter")

                let tweetbot = NSURL(string: "tweetbot://current/user_profile/genadyo")!
                let twitterrific = NSURL(string: "twitterrific://current/profile?screen_name=genadyo")!
                let twitter = NSURL(string: "twitter://user?screen_name=genadyo")!
                let safari = NSURL(string: "https://twitter.com/genadyo")!

                if UIApplication.sharedApplication().canOpenURL(tweetbot) {
                    UIApplication.sharedApplication().openURL(tweetbot)
                } else {
                    if UIApplication.sharedApplication().canOpenURL(twitterrific) {
                        UIApplication.sharedApplication().openURL(twitterrific)
                    } else {
                        if UIApplication.sharedApplication().canOpenURL(twitter) {
                            UIApplication.sharedApplication().openURL(twitter)
                        } else {
                            if UIApplication.sharedApplication().canOpenURL(safari) {
                                UIApplication.sharedApplication().openURL(safari)
                            } else {
                                let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .Alert)
                                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                                    alert.dismissViewControllerAnimated(true, completion: nil)
                                }
                                alert.addAction(ok)
                                presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else if indexPath.item == 2 {
                Mixpanel.sharedInstance().track("Email")

                if MFMailComposeViewController.canSendMail() {
                    let mailComposeViewController = MFMailComposeViewController()
                    mailComposeViewController.mailComposeDelegate = self
                    mailComposeViewController.setToRecipients(["genady@okrain.com"])
                    mailComposeViewController.setSubject(NSLocalizedString("Parties", comment: ""))

                    let infoDictionary = NSBundle.mainBundle().infoDictionary as! [String : AnyObject]
                    let version = infoDictionary["CFBundleShortVersionString"] as! String!
                    let build = infoDictionary["CFBundleVersion"] as! String!
                    var systemInfo = [UInt8](count: sizeof(utsname), repeatedValue: 0)
                    let model = systemInfo.withUnsafeMutableBufferPointer { (inout body: UnsafeMutableBufferPointer<UInt8>) -> String? in
                        if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                            return nil
                        }
                        return String.fromCString(UnsafePointer(body.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))))
                    }

                    var body = "<br><br><br><br><br><br><br><br><br>"
                    body += "<hr>"
                    body += "App Version: " + version + "<br>"
                    body += "App Build: " + build + "<br>"
                    if let model = model {
                        body += "Device Model: " + model + "<br>"
                    }
                    body += "Device Version: " + UIDevice.currentDevice().systemVersion
                    body += "<hr>"

                    mailComposeViewController.setMessageBody(body, isHTML: true)
                    presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Failed to send mail", comment: ""), message: nil, preferredStyle: .Alert)
                    let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(ok)
                    presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else if indexPath.section == 1 {
            switch indexPath.item {
            case 0:
                url = NSURL(string: "https://github.com/orta/cocoapods-keys")
            case 1:
                url = NSURL(string: "https://github.com/mutualmobile/MMWormhole")
            case 2:
                url = NSURL(string: "https://useiconic.com/open/")
            case 3:
                url = NSURL(string: "https://github.com/tumblr/TMCache")
            case 4:
                url = NSURL(string: "https://github.com/davbeck/TUSafariActivity")
            default:
                break
            }

            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Failed to open url", comment: ""), message: nil, preferredStyle: .Alert)
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { _ in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let infoDictionary = NSBundle.mainBundle().infoDictionary as! [String : AnyObject]
            let version = infoDictionary["CFBundleShortVersionString"] as! String!
            let build = infoDictionary["CFBundleVersion"] as! String!
            let label = UILabel()
            label.text = NSLocalizedString("Version \(version) (\(build))", comment: "")
            label.textColor = UIColor.grayColor()
            label.font = UIFont(name: "HelveticaNeue-Light", size: 17)!
            label.textAlignment = .Center
            return label
        } else {
            return nil
        }
    }

    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
