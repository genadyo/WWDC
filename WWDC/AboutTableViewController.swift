//
//  AboutTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 3/24/15.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import SafariServices
import Smooch

class AboutTableViewController: UITableViewController {
    fileprivate func openTwitter(_ username: String) {
        let urls = ["tweetbot://current/user_profile/\(username)", "twitterrific://current/profile?screen_name=\(username)", "twitter://user?screen_name=\(username)"]
        for url in urls {
            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }

        openURL("https://twitter.com/\(username)")
    }

    fileprivate func openURL(_ string: String) {
        if let url = URL(string: string) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }

    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func share(_ sender: AnyObject) {
        let text = "Parties for WWDC"
        if let url = URL(string: "https://itunes.apple.com/us/app/parties-for-wwdc/id879924066?ls=1&mt=8") {
            let activityItems = [text, url] as [Any]
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }

    // MARK: UITableViewControllerDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=879924066&pageNumber=0&sortOrdering=1&onlyLatestVersion=true&action=write-review"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else if indexPath.row == 1 {
                openTwitter("genadyo")
            } else if indexPath.row == 2 {
                Smooch.show()
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
}
