//
//  BattleSummaryTableViewCell.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/22/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class BattleSummaryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func configure(for battle: Battle) {
        guard let recipient = battle.recipient else {
            textLabel?.text = "Buggy Battle"
            detailTextLabel?.text = "no recipient"
            return
        }
        let initiator = battle.initiator

        switch battle.state {
        case .cancelledByInitiator:
            textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            detailTextLabel?.text = "withdrawn by \(initiator.screenname)"

        case .open:
            textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            detailTextLabel?.text = "waiting for \(recipient.screenname) to accept"

        case .declinedByRecipient:
            textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            detailTextLabel?.text = "declined by \(recipient.screenname)"

        case .pending:
            textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
            detailTextLabel?.text = "it's on!"

        case .complete:
            switch battle.outcome {
            case .initiatorWin:
                textLabel?.text = "\(initiator.screenname) wins"
                if battle.isDisputed { textLabel?.text! += " *" }
                detailTextLabel?.text = "defeats \(recipient.screenname)"

            case .initiatorLoss:
                textLabel?.text = "\(recipient.screenname) wins!"
                if battle.isDisputed { textLabel?.text! += " *" }
                detailTextLabel?.text = "defeats \(initiator.screenname)"

            case .noContest:
                textLabel?.text = "\(initiator.screenname) v \(recipient.screenname)"
                detailTextLabel?.text = "no contest"

            case .TBD:
                textLabel?.text = "Buggy Battle"
                detailTextLabel?.text = "Complete but outcome is TBD"
            }
        }
    }

}
