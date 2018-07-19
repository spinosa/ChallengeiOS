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

    lazy var refreshControl: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(HomeViewController.reloadAllData), for: UIControlEvents.valueChanged)
        refresher.tintColor = UIColor(named: "GlobalTintColor")
        return refresher
    }()

    private var battles: [Battle] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
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

    @objc private func reloadAllData() {
        Webservice.forCurrentUser.load(Battle.all) { (allBattles) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
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

    public func showCreatedBattle(_ battle: Battle) {
        battles.insert(battle, at: 0)
        let idx = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [idx], with: .top)
        self.tableView.selectRow(at: idx, animated: true, scrollPosition: .top)
        self.performSegue(withIdentifier: "battleSelectedSegue", sender: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: BattleSummaryTableViewCell.ReuseIdentifier, for: indexPath)
        let battle = self.battles[indexPath.row]

        if let battleSummaryCell = cell as? BattleSummaryTableViewCell {
            battleSummaryCell.battle = battle
        }

        return cell
    }

    //MARK: Swipe to Delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return User.currentUser?.isRoot ?? false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDelete(forRowAt: indexPath)
        }
    }

    private func confirmDelete(forRowAt indexPath: IndexPath) {
        let battle = battles[indexPath.row]

        let alertController = UIAlertController(title: "Delete Battle", message: "Are you sure you want to delete this battle?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            Webservice.forCurrentUser.delete(battle.resource(), instance: battle, completion: { urlResult in
                if let r = urlResult as? HTTPURLResponse, 200...299 ~= r.statusCode {
                    DispatchQueue.main.async {
                        self.battles.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                    }
                }
            })
        }))
        alertController.addAction(UIAlertAction(title: "Keep", style: .default, handler: { _ in
            //nothing to do on cancel
        }))
        present(alertController, animated: true, completion: nil)
    }
}
