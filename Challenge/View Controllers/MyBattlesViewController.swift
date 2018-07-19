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
    enum Sections: Int {
        case Active = 0, Archive
    }

    lazy var refreshControl: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(MyBattlesViewController.reloadAllData), for: UIControlEvents.valueChanged)
        refresher.tintColor = UIColor(named: "GlobalTintColor")
        return refresher
    }()

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

        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: "BattleSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: BattleSummaryTableViewCell.ReuseIdentifier)
        
        NotificationCenter.default.addObserver(forName: User.DidSetCurrentUser, object: nil, queue: OperationQueue.main) { (_) in
            self.reloadAllData()
        }

        if User.currentUser != nil {
            reloadAllData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let selectedidx = self.tableView?.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedidx, animated: true)
        }
    }

    @objc private func reloadAllData() {
        Webservice.forCurrentUser.load(Battle.myActive) { (battles) in
            if let battles = battles {
                self.activeBattles = battles
            }
        }
        Webservice.forCurrentUser.load(Battle.myArchive) { (battles) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            if let battles = battles {
                self.archiveBattles = battles
            }
        }
    }

    public func showBattle(id: String) {
        Webservice.forCurrentUser.load(Battle.show(id: id)) { (battle) in
            if let battle = battle {
                if let battleDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "BattleDetailsViewController") as? BattleDetailsViewController {
                    battleDetailsVC.battle = battle
                    battleDetailsVC.didUpdateBattle = self.findAndUpdateBattle
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(battleDetailsVC, animated: true)
                        //XXX instead of inserting battle into data model,
                        // try to make sure it's there ...in an mvp way =)
                        self.reloadAllData()
                    }
                }
            }
        }
    }

    public func showCreatedBattle(_ battle: Battle) {
        activeBattles.insert(battle, at: 0)
        let idx = IndexPath(row: 0, section: Sections.Active.rawValue)
        self.tableView.insertRows(at: [idx], with: .top)
        self.tableView.selectRow(at: idx, animated: true, scrollPosition: .top)
        self.performSegue(withIdentifier: "battleSelectedSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let battleDetailsVC = segue.destination as? BattleDetailsViewController,
            let selectedBattle = selectedBattle() {
            battleDetailsVC.battle = selectedBattle
            battleDetailsVC.didUpdateBattle = self.findAndUpdateBattle
        }
    }

    private func findAndUpdateBattle(_ battle: Battle) {
        DispatchQueue.main.async {
            if let idx = self.indexPathFor(battle: battle) {
                self.update(indexPath: idx, with: battle)
            }
        }
    }

    private func update(indexPath: IndexPath, with battle: Battle) {
        switch indexPath.section {
        case Sections.Active.rawValue:
            activeBattles[indexPath.row] = battle
        case Sections.Archive.rawValue:
            archiveBattles[indexPath.row] = battle
        default:
            preconditionFailure("Unhandled section")
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
            return "Active"
        case Sections.Archive.rawValue:
            return "Completed"
        default:
            preconditionFailure("Unhandled section")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.Active.rawValue:
            return activeBattles.count
        case Sections.Archive.rawValue:
            return archiveBattles.count
        default:
            preconditionFailure("Unhandled section")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BattleSummaryTableViewCell.ReuseIdentifier, for: indexPath)

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
            battleSummaryCell.battle = battle
        }

        return cell
    }

}

//MARK: - Data Model Helpers
extension MyBattlesViewController {

    private func selectedBattle() -> Battle? {
        guard let selectedidx = tableView.indexPathForSelectedRow else { return nil }
        switch selectedidx.section {
        case Sections.Active.rawValue:
            return activeBattles[selectedidx.row]
        case Sections.Archive.rawValue:
            return archiveBattles[selectedidx.row]
        default:
            preconditionFailure("Unhandled section")
        }
    }

    private func indexPathFor(battle: Battle) -> IndexPath? {
        if let row = activeBattles.index(where: { $0.id == battle.id }) {
            return IndexPath(row: row, section: Sections.Active.rawValue)
        }
        if let row = archiveBattles.index(where: { $0.id == battle.id }) {
            return IndexPath(row: row, section: Sections.Archive.rawValue)
        }
        return nil
    }

}
