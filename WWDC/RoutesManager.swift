//
//  PartiesManager.swift
//  SFParties
//
//  Created by Genady Okrain on 4/13/17.
//  Copyright © 2017 Okrain. All rights reserved.
//

import Foundation
import JLRoutes

class RoutesManager {
    static let sharedInstance = RoutesManager()

    var topViewController: UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }

    private func showParty(objectId: String, topViewController: UISplitViewController) -> Bool {
        guard let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "partyNVC") as? PartyNavigationController, let vc = nvc.viewControllers.first as? PartyTableViewController else { return false }

        let party = PartiesManager.sharedInstance.parties.filter({ partiesForDay -> Bool in
            return partiesForDay.filter({ party -> Bool in
                return party.objectId == objectId
            }).count > 0
        }).first?.first

        if let party = party {
            vc.party = party
            vc.delegate = ((topViewController.viewControllers.first as? UINavigationController)?.viewControllers.first as? PartiesViewController)?.partiesTableViewController
            topViewController.showDetailViewController(nvc, sender: nil)
            return true
        } else {
            return false
        }
    }

    func setup() {
        JLRoutes.global().addRoute("/party/:objectId") { [weak self] params in
            guard let objectId = params["objectId"] as? String, let topViewController = self?.topViewController as? UISplitViewController else { return false }

            if self?.showParty(objectId: objectId, topViewController: topViewController) == true {
                return true
            } else {
                PartiesManager.sharedInstance.load() {
                    _ = self?.showParty(objectId: objectId, topViewController: topViewController)
                }
                return true
            }
        }
    }
}
