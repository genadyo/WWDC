//
//  PartyNavigationController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit

class PartyNavigationController: UINavigationController {
    override var previewActionItems : [UIPreviewActionItem] {
        let open = UIPreviewAction(title: "Open in Safari", style: .default) { [weak self] action, previewViewController in
            if let vc = self?.viewControllers[0] as? PartyTableViewController {
                UIApplication.shared.open(vc.party.url, options: [:], completionHandler: nil)
            }
        }

        let walk = UIPreviewAction(title: "Walking Directions", style: .default) { [weak self] action, previewViewController in
            if let vc = self?.viewControllers[0] as? PartyTableViewController {
                vc.openMaps(action)
            }
        }

        return [open, walk]
    }
}
