//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import UIKit
import UnifyID
import GaitAuth

class InfoTableViewController: UITableViewController {
    let bundles = [
        Bundle.main,
        Bundle(for: UnifyID.self),
        Bundle(for: GaitAuth.self)
    ].compactMap { $0 }

    var details: [(String, String?)] = [] {
        didSet {
            tableView.setNeedsLayout()
        }
    }

    var disclosures: [(title: String, url: URL)] = [
        // swiftlint:disable:next force_unwrapping
        ("Privacy Policy", URL(string: "https://unify.id/privacy-policy/")!)
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        details = [
            ("Client ID", unifyid.core?.clientID),
            ("Install ID", UnifyID.installID),
            ("User", unifyid.core?.user),
            ("Model ID", unifyid.modelID)
        ]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return bundles.count
        case 1:
            return details.count
        case 2:
            return disclosures.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Software Version"
        case 1:
            return "Debugging Information"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            let info = bundles[indexPath.row]
            cell.textLabel?.text = info.name
            cell.detailTextLabel?.text = info.version
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)
            cell.textLabel?.text = details[indexPath.row].0
            cell.detailTextLabel?.text = details[indexPath.row].1 ?? "not set"
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
            cell.textLabel?.text = disclosures[indexPath.row].title
            cell.detailTextLabel?.text = nil
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
        }

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0, 1: return true
        default: return false
        }
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        guard action == #selector(copy(_:)) else {
            return
        }

        guard let text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text else {
            return
        }

        UIPasteboard.general.string = text
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2, indexPath.row < disclosures.count else { return }
        UIApplication.shared.open(disclosures[indexPath.row].url)
    }
}
