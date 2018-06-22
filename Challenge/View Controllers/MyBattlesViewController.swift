//
//  MyBattlesViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/22/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class MyBattlesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var activeBattles: [Battle] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadSections([Sections.Active.rawValue], with: .automatic)
            }
        }
    }

    private var archiveBattles: [Battle] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadSections([Sections.Archive.rawValue], with: .automatic)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: User.DidSetCurrentUser, object: nil, queue: OperationQueue.main) { (_) in
            self.reloadAllData()
        }

        reloadAllData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadAllData()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let selectedidx = self.tableView?.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedidx, animated: true)
        }
    }

    private func reloadAllData() {
        Webservice.forCurrentUser.load(Battle.myActive) { (battles) in
            if let battles = battles {
                self.activeBattles = battles
            }
        }
        Webservice.forCurrentUser.load(Battle.myArchive) { (battles) in
            if let battles = battles {
                self.archiveBattles = battles
            }
        }
    }

    enum Sections: Int {
        case Active = 0, Archive
    }
}

extension MyBattlesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        //TODO use Sections.all.count
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Sections.Active.rawValue:
            return "Active Challenges"
        case Sections.Archive.rawValue:
            return "Archived Challenges"
        default:
            assertionFailure("unhandled section")
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.Active.rawValue:
            return activeBattles.count
        case Sections.Archive.rawValue:
            return archiveBattles.count
        default:
            assertionFailure("unhandled section")
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "battleSummaryCell", for: indexPath)

        let battle: Battle
        switch indexPath.section {
        case Sections.Active.rawValue:
            battle = activeBattles[indexPath.row]
        case Sections.Archive.rawValue:
            battle = archiveBattles[indexPath.row]
        default:
            assertionFailure("unhandled section")
            battle = activeBattles[0]
        }

        if let battleSummaryCell = cell as? BattleSummaryTableViewCell {
            battleSummaryCell.configure(for: battle)
        }

        return cell
    }

}
