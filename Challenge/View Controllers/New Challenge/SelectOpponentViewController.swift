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

    var usernameSearchResults: [User]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    enum Sections: Int {
        case Username = 0, UsernameSearchResults
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
            let usernameSelectionCell = tableView.dequeueReusableCell(withIdentifier: "usernameSelectionCell", for: indexPath) as! UsernameSelectionTableViewCell
            usernameSelectionCell.delegate = self
            return usernameSelectionCell
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
}

extension SelectOpponentViewController: UsernameSelectionTableViewCellDelegate {

    func setUsers(_ users: [User]?, matching username: String) {
        self.usernameSearchResults = users
        DispatchQueue.main.async {
            self.tableView.reloadSections([Sections.UsernameSearchResults.rawValue], with: .automatic)
        }
    }

}
