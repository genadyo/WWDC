//
//  PartiesTableViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 4/27/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import UIKit
import CoreLocation

protocol PartiesTableViewControllerDelegate {
    func load(_ completion: (() -> Void)?)
}

class PartiesTableViewController: UITableViewController, PartyTableViewControllerDelegate, UIViewControllerPreviewingDelegate {
    var selectedSegmentIndex = 0 {
        didSet {
            reloadData()
        }
    }

    var delegate: PartiesTableViewControllerDelegate?

    var parties = PartiesManager.sharedInstance.parties

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollToTop()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Peek & Pop
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    func scrollToTop() {
        guard parties.count > 0 else { return }

        for i in 0..<parties.count {
            let partiesForDay = parties[i]
            if let index = partiesForDay.index(where: { $0.startDate > Date() }), index > 0 {
                tableView.scrollToRow(at: IndexPath(row: index, section: i), at: .top, animated: true)
                return
            }
        }
    }

    @IBAction func refresh(_ sender: UIRefreshControl?) {
        delegate?.load() {
            sender?.endRefreshing()
        }
    }

    func buttonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "map", sender: sender)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return 1
        } else {
            return parties.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return 1
        } else {
            return parties[section].count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "party", for: indexPath) as! PartyTableViewCell
            let party = parties[indexPath.section][indexPath.row]
            cell.party = party
            cell.separatorView.isHidden = parties[indexPath.section].count == indexPath.row+1
            cell.contentView.alpha = Date() > party.endDate ? 0.3 : 1.0
            return cell
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            let navigationControllerHeight = navigationController?.navigationBar.frame.size.height ?? 0
            return UIScreen.main.bounds.size.height-navigationControllerHeight-UIApplication.shared.statusBarFrame.size.height
        } else {
            return 75
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedSegmentIndex == 1 && parties.count == 0 {
            return 0
        } else {
            return 40
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        if !(selectedSegmentIndex == 1 && parties.count == 0) && parties.count > section && parties[section].count > 0 {
            view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40.0))
            view.autoresizingMask = .flexibleWidth

            let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40.0))
            bgView.autoresizingMask = .flexibleWidth
            bgView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            view.addSubview(bgView)

            let label = UILabel(frame: CGRect(x: 8.0, y: 0.0, width: tableView.frame.size.width-22.0*2, height: 40.0))
            if let lastEndDate = parties[section].last?.endDate {
                label.alpha = Date() > lastEndDate ? 0.3 : 1.0
            }
            label.autoresizingMask = .flexibleRightMargin
            label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightRegular)
            label.text = parties[section].first?.date
            label.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            view.addSubview(label)

            let mapImageView = UIImageView(image: UIImage(named: "map"))
            if let lastEndDate = parties[section].last?.endDate {
                mapImageView.alpha = Date() > lastEndDate ? 0.3 : 1.0
            }
            mapImageView.autoresizingMask = .flexibleLeftMargin
            mapImageView.frame = CGRect(x: tableView.frame.size.width-33.0, y: 6.0, width: 20.0, height: 28.0)
            view.addSubview(mapImageView)

            let button = UIButton(type: .custom)
            button.autoresizingMask = .flexibleWidth
            button.frame = view.frame
            button.addTarget(self, action: #selector(PartiesTableViewController.buttonClicked(_:)), for: .touchDown)
            button.tag = section
            view.addSubview(button)
        }
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "party", sender: indexPath)
    }

    // MARK: PartyTableViewControllerDelegate

    func reloadData() {
        if selectedSegmentIndex == 0 {
            parties = PartiesManager.sharedInstance.parties
            tableView.isScrollEnabled = true
        } else {
            var pparties = [[Party]]()
            for p in PartiesManager.sharedInstance.parties {
                let filteredP = p.filter({ $0.isGoing })
                if filteredP.count > 0 {
                    pparties.append(filteredP)
                }
            }
            parties = pparties
            tableView.isScrollEnabled = parties.count > 0
        }
        tableView.reloadData()
    }

    // MARK: UIViewControllerPreviewingDelegate

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) as? PartyTableViewCell, let nvc = storyboard?.instantiateViewController(withIdentifier: "partyNVC") as? PartyNavigationController, let vc = nvc.viewControllers.first as? PartyTableViewController, tableView.bounds.contains(tableView.rectForRow(at: indexPath)) else { return nil }
        previewingContext.sourceRect = cell.frame
        vc.party = parties[indexPath.section][indexPath.row]
        return nvc
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nvc = segue.destination as? PartyNavigationController, let vc = nvc.viewControllers.first as? PartyTableViewController, let indexPath = sender as? IndexPath, segue.identifier == "party" {
            vc.delegate = self
            vc.party = parties[indexPath.section][indexPath.row]
        } else if let nvc = segue.destination as? UINavigationController, let vc = nvc.viewControllers.first as? MapDayViewController, let button = sender as? UIButton, segue.identifier == "map" {
            vc.navigationItem.title = parties[button.tag].first?.date
            vc.parties = parties[button.tag]
        }
    }
}
