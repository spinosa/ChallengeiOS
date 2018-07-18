//
//  BattleDetailsViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/20/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class BattleDetailsViewController: UIViewController {

    @IBOutlet weak var initiatorLabel: UILabel!
    @IBOutlet weak var battleVerbLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var disputeDisclosureLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var iWonButton: UIButton!
    @IBOutlet weak var iLostButton: UIButton!
    @IBOutlet weak var noContestButton: UIButton!
    @IBOutlet weak var disputeButton: UIButton!

    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet var outcomeButtons: [UIButton]!

    public var battle: Battle? = nil {
        didSet {
            if let battle = battle {
                self.didUpdateBattle?(battle)
                DispatchQueue.main.async {
                    self.updateView()
                }
            }
        }
    }

    public var didUpdateBattle: ((Battle)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }

    private func updateView() {
        guard let battle = battle, let recipient = battle.recipient else { return }
        let initiator = battle.initiator
        loadViewIfNeeded()

        self.allButtons.forEach({ $0.isHidden = true })

        switch battle.battleType {
        case .Challenge:
            battleVerbLabel.text = "v"
        case .Dare:
            battleVerbLabel.text = "dares"
        }

        switch battle.state {
        case .open:
            self.title = "Proposed"
            if User.currentUser == battle.recipient {
                self.acceptButton.isHidden = false
            }

        case .cancelledByInitiator:
            self.title = "Revoked"
            self.navigationItem.prompt = "\(initiator.screenname) revoked"

        case .declinedByRecipient:
            self.title = "Declined"
            self.navigationItem.prompt = "\(recipient.screenname) declined"

        case .pending:
            self.title = "Underway..."
            if User.currentUser == battle.recipient {
                self.outcomeButtons.forEach({ $0.isHidden = false })
            }

        case .complete:
            guard let winner = battle.winner else {
                self.title = "Settled"
                assertionFailure("complete battle without winner")
                return
            }

            switch battle.outcome {
            case .initiatorWin: fallthrough
            case .initiatorLoss:
                self.title = "\(winner.screenname) won"
                if battle.isDisputed { self.title! += "*" }
            case .noContest:
                self.title = "No contest"
            default:
                assertionFailure("unhandled outcome")
                self.title = "Settled"
            }

            if User.currentUser == battle.initiator && !battle.isDisputed {
                self.disputeButton.isHidden = false
            }
        }

        initiatorLabel.text = initiator.screenname
        recipientLabel.text = recipient.screenname

        descriptionLabel.text = battle.description

        disputeDisclosureLabel.isHidden = !battle.isDisputed
        if let disputedBy = battle.disputedBy {
            disputeDisclosureLabel.text = "* disputed by \(disputedBy.screenname)"
        }
    }

    // ----- Actions -----
    @IBAction func acceptChallenge(_ sender: Any) {
        guard let battle = battle else { return }

        Webservice.forCurrentUser.post(battle.accept()) { [weak self] updatedBattle, resp in
            self?.battle = updatedBattle
        }
    }

    @IBAction func iWon(_ sender: Any) {
        guard let battle = battle else { return }
        assert(User.currentUser == battle.recipient, "only recipient should be able to say they won")
        guard User.currentUser == battle.recipient else { return }

        Webservice.forCurrentUser.post(battle.complete(outcome: .initiatorLoss)) { [weak self] updatedBattle, resp in
            self?.battle = updatedBattle
        }
    }

    @IBAction func iLost(_ sender: Any) {
        guard let battle = battle else { return }
        assert(User.currentUser == battle.recipient, "only recipient should be able to say they won")
        guard User.currentUser == battle.recipient else { return }

        Webservice.forCurrentUser.post(battle.complete(outcome: .initiatorWin)) { [weak self] updatedBattle, resp in
            self?.battle = updatedBattle
        }
    }

    @IBAction func noContest(_ sender: Any) {
        guard let battle = battle else { return }
        assert(User.currentUser == battle.recipient, "only recipient should be able to say they won")
        guard User.currentUser == battle.recipient else { return }

        Webservice.forCurrentUser.post(battle.complete(outcome: .noContest)) { [weak self] updatedBattle, resp in
            self?.battle = updatedBattle
        }
    }

    @IBAction func dispute(_ sender: Any) {
        guard let battle = battle else { return }
        assert(User.currentUser == battle.initiator, "only initiator should be able to dispute ")
        guard User.currentUser == battle.initiator else { return }

        Webservice.forCurrentUser.post(battle.dispute()) { [weak self] updatedBattle, resp in
            self?.battle = updatedBattle
        }
    }

}
