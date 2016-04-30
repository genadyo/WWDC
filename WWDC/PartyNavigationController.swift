//
//  PartyNavigationController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit

class PartyNavigationController: UINavigationController {
    override func previewActionItems() -> [UIPreviewActionItem] {
        let open = UIPreviewAction(title: "Open in Safari", style: .Default) { [weak self] action, previewViewController in
            if let vc = self?.viewControllers[0] as? PartyTableViewController {
                UIApplication.sharedApplication().openURL(vc.party.url)
            }
        }

        let walk = UIPreviewAction(title: "Walking Directions", style: .Default) { [weak self] action, previewViewController in
            if let vc = self?.viewControllers[0] as? PartyTableViewController {
                vc.openMaps(action)
            }
        }

        let lyft = UIPreviewAction(title: "Request Lyft Line", style: .Default) { [weak self] action, previewViewController in
            if let vc = self?.viewControllers[0] as? PartyTableViewController {
                vc.openLyft(action)
            }
        }

        return [open, walk, lyft]
    }
}
