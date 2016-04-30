//
//  AboutTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 3/24/15.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    private func openTwitter(username: String) {
        let urls = ["tweetbot://current/user_profile/\(username)", "twitterrific://current/profile?screen_name=\(username)", "twitter://user?screen_name=\(username)"]
        for url in urls {
            if let url = NSURL(string: url) where UIApplication.sharedApplication().canOpenURL(url) {
                if UIApplication.sharedApplication().openURL(url) == true {
                    return
                }
            }
        }

        openURL("https://twitter.com/\(username)")
    }

    private func openURL(string: String) {
        if let url = NSURL(string: string) {
            let safariViewController = SFSafariViewController(URL: url)
            presentViewController(safariViewController, animated: true, completion: nil)
        }
    }

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func share(sender: AnyObject) {
        let text = "Parties for WWDC"
        if let url = NSURL(string: "https://itunes.apple.com/us/app/parties-for-wwdc/id879924066?ls=1&mt=8") {
            let activityItems = [text, url]
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            presentViewController(activityViewController, animated: true, completion: nil)
        }
    }

    // MARK: UITableViewControllerDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let url = NSURL(string: "itms-apps://itunes.apple.com/app/id879924066") where UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            } else if indexPath.row == 1 {
                openTwitter("genadyo")
            } else if indexPath.row == 2 {
                if MFMailComposeViewController.canSendMail() == true {
                    let mailComposeViewController = MFMailComposeViewController()
                    mailComposeViewController.mailComposeDelegate = self
                    mailComposeViewController.setToRecipients(["genady@okrain.com"])
                    mailComposeViewController.setSubject("Parties for WWDC")

                    var body = "<br><br><br><br><br><br><br><br><br><hr>"

                    if let infoDictionary = NSBundle.mainBundle().infoDictionary {
                        if let version = infoDictionary["CFBundleShortVersionString"] as? String {
                            body += "App Version: " + version + "<br>"
                        }

                        if let build = infoDictionary["CFBundleVersion"] as? String {
                            body += "App Build: " + build + "<br>"
                        }
                    }

                    var systemInfo = [UInt8](count: sizeof(utsname), repeatedValue: 0)
                    let model = systemInfo.withUnsafeMutableBufferPointer { (inout body: UnsafeMutableBufferPointer<UInt8>) -> String? in
                        if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                            return nil
                        }
                        return String.fromCString(UnsafePointer(body.baseAddress.advancedBy(Int(_SYS_NAMELEN*4))))
                    }
                    if let model = model {
                        body += "Device Model: " + model + "<br>"
                    }

                    body += "Device Version: " + UIDevice.currentDevice().systemVersion

                    body += "<hr>"

                    mailComposeViewController.setMessageBody(body, isHTML: true)

                    presentViewController(mailComposeViewController, animated: true, completion: nil)
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                openURL("https://github.com/orta/cocoapods-keys")
            } else if indexPath.row == 1 {
                openURL("https://useiconic.com/open/")
            } else if indexPath.row == 2 {
                openURL("https://github.com/pinterest/PINRemoteImage")
            }
        }
    }

    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
