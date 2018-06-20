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

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Webservice.forCurrentUser.load(Battle.all) { (allBattles) in
            if let allBattles = allBattles {
                self.battles = allBattles
            }
        }
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return battles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicBattle", for: indexPath)
        let battle = self.battles[indexPath.row]

        configure(cell, for: battle)

        return cell
    }

    private func configure(_ cell: UITableViewCell, for battle: Battle) {
        guard let recipient = battle.recipient else {
            cell.textLabel?.text = "Buggy Battle"
            cell.detailTextLabel?.text = "no recipient"
            return
        }
        let initiator = battle.initiator

        switch battle.state {
        case .cancelledByInitiator:
            cell.textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            cell.detailTextLabel?.text = "withdrawn by \(initiator.screenname)"

        case .open:
            cell.textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            cell.detailTextLabel?.text = "waiting for \(recipient.screenname) to accept"

        case .declinedByRecipient:
            cell.textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            cell.detailTextLabel?.text = "declined by \(recipient.screenname)"

        case .pending:
            cell.textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            cell.detailTextLabel?.text = "it's on!"

        case .complete:
            switch battle.outcome {
            case .initiatorWin:
                cell.textLabel?.text = "\(initiator.screenname) wins!"
                cell.detailTextLabel?.text = "defeating \(recipient.screenname)"

            case .initiatorLoss:
                cell.textLabel?.text = "\(recipient.screenname) wins!"
                cell.detailTextLabel?.text = "defeating \(initiator.screenname)"

            case .noContest:
                cell.textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
                cell.detailTextLabel?.text = "no contest"

            case .TBD:
                cell.textLabel?.text = "Buggy Battle"
                cell.detailTextLabel?.text = "Complete but outcome is TBD"
            }
        }

    }
}
