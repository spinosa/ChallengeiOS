//
//  HomeViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/20/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var battles: [Battle] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    public func showCreatedBattle(_ battle: Battle) {
        battles.insert(battle, at: 0)
        let idx = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [idx], with: .top)
        self.tableView.selectRow(at: idx, animated: true, scrollPosition: .top)
        self.performSegue(withIdentifier: "battleSelectedSegue", sender: nil)
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
        Webservice.forCurrentUser.load(Battle.all) { (allBattles) in
            if let allBattles = allBattles {
                self.battles = allBattles
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let battleDetailsVC = segue.destination as? BattleDetailsViewController,
            let (selectedBattle, selectedIdx) = selectedBattle() {
            battleDetailsVC.battle = selectedBattle
            battleDetailsVC.didUpdateBattle = { battle in
                DispatchQueue.main.async {
                    self.update(indexPath: selectedIdx, with: battle)
                }
            }
        }
    }

    private func selectedBattle() -> (Battle, IndexPath)? {
        guard let selectedidx = tableView.indexPathForSelectedRow else { return nil }
        guard selectedidx.section == 0 else { return nil }
        return (battles[selectedidx.row], selectedidx)
    }

    private func update(indexPath: IndexPath, with battle: Battle) {
        battles[indexPath.row] = battle
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return battles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "battleSummaryCell", for: indexPath)
        let battle = self.battles[indexPath.row]

        if let battleSummaryCell = cell as? BattleSummaryTableViewCell {
            battleSummaryCell.configure(for: battle)
        }

        return cell
    }

}
