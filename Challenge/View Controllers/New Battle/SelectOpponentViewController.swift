//
//  SelectOpponentViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/20/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class SelectOpponentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var usernameSelectionCell: UsernameSelectionTableViewCell?

    var usernameSearchResults: [User]? = nil {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadSections([Sections.UsernameSearchResults.rawValue], with: .automatic)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: Battle.DidCreateBattle, object: nil, queue: OperationQueue.main) { [weak self] (note) in
            if let _ = note.userInfo?[Battle.CreatedBattleKey] as? Battle {
                self?.reset()
            }
        }
    }

    enum Sections: Int {
        case Username = 0, UsernameSearchResults
    }

    private func reset() {
        self.usernameSearchResults = nil
        self.usernameSelectionCell?.reset()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createBattleVC = segue.destination as? CreateBattleViewController {
            if let selectedIP = tableView.indexPathForSelectedRow, selectedIP.section == Sections.UsernameSearchResults.rawValue,
                let opponent = usernameSearchResults?[selectedIP.row] {
                createBattleVC.opponent = opponent
            }
        }
    }
}

extension SelectOpponentViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        //TODO: use Swift 4 auto generated .all
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.Username.rawValue:
            return 1
        case Sections.UsernameSearchResults.rawValue:
            return usernameSearchResults?.count ?? 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.Username.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "usernameSelectionCell", for: indexPath) as! UsernameSelectionTableViewCell
            usernameSelectionCell = cell
            cell.delegate = self
            return cell
        case Sections.UsernameSearchResults.rawValue:
            let usernameSearchResultCell = tableView.dequeueReusableCell(withIdentifier: "usernameSearchResultCell", for: indexPath)
            let user = usernameSearchResults![indexPath.row]
            usernameSearchResultCell.textLabel?.text = user.screenname
            usernameSearchResultCell.detailTextLabel?.text = "\(user.winsTotal) Wins - \(user.lossesTotal) Losses"
            return usernameSearchResultCell
        default:
            assertionFailure("Unhandled Section")
            return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case Sections.Username.rawValue:
            return false
        default:
            return true
        }
    }
}

extension SelectOpponentViewController: UsernameSelectionTableViewCellDelegate {

    func setUsers(_ users: [User]?, matching username: String) {
        self.usernameSearchResults = users
    }

}
