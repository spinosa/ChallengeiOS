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
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    public var battle: Battle? = nil {
        didSet {
            if battle != nil {
                updateView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }

    private func updateView() {
        guard let battle = battle, let recipient = battle.recipient else { return }
        let initiator = battle.initiator
        loadViewIfNeeded()

        switch battle.state {
        case .open:
            self.title = "Proposed"
        case .cancelledByInitiator:
            self.title = "Revoked"
            self.navigationItem.prompt = "\(initiator.screenname) revoked"
        case .declinedByRecipient:
            self.title = "Declined"
            self.navigationItem.prompt = "\(recipient.screenname) declined"
        case .pending:
            self.title = "Underway..."
        case .complete:
            self.title = "Settled"
        }

        initiatorLabel.text = initiator.screenname
        recipientLabel.text = recipient.screenname

        descriptionLabel.text = battle.description
    }

}
