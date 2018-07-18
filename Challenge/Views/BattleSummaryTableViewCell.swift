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
            textLabel?.text = headline(initiator, v: recipient, perspective: User.currentUser, in: battle)
            detailTextLabel?.text = "withdrawn by \(initiator.screenname)"

        case .open:
            textLabel?.text = headline(initiator, v: recipient, perspective: User.currentUser, in: battle)
            User.currentUser == recipient ?
                (detailTextLabel?.text = "waiting for you to accept") :
                (detailTextLabel?.text = "waiting for \(recipient.screenname) to accept")

        case .declinedByRecipient:
            textLabel?.text = headline(initiator, v: recipient, perspective: User.currentUser, in: battle)
            detailTextLabel?.text = "declined by \(recipient.screenname)"

        case .pending:
            textLabel?.text = headline(initiator, v: recipient, perspective: User.currentUser, in: battle)
            detailTextLabel?.text = "it's on!"

        case .complete:
            switch battle.outcome {
            case .initiatorWin:
                User.currentUser == initiator ?
                    (textLabel?.text = "You won!") :
                    (textLabel?.text = "\(initiator.screenname) wins")
                if battle.isDisputed { textLabel?.text! += " *" }
                detailTextLabel?.text = "defeating \(recipient.screenname)"

            case .initiatorLoss:
                User.currentUser == recipient ?
                    (textLabel?.text = "You won!") :
                    (textLabel?.text = "\(recipient.screenname) wins")
                if battle.isDisputed { textLabel?.text! += " *" }
                detailTextLabel?.text = "defeating \(initiator.screenname)"

            case .noContest:
                textLabel?.text = headline(initiator, v: recipient, perspective: User.currentUser, in: battle)
                detailTextLabel?.text = "no contest"

            case .TBD:
                textLabel?.text = "Buggy Battle"
                detailTextLabel?.text = "Complete but outcome is TBD"
            }
        }
    }

    private func headline(_ initiator: User, v recipient: User, perspective: User?, in battle: Battle) -> String {
        if let viewer = perspective {
            if viewer == initiator {
                switch battle.battleType {
                case .Challenge:
                    return "You v \(recipient.screenname)"
                case .Dare:
                    return "You dared \(recipient.screenname)"
                }
            }
            if viewer == recipient {
                switch battle.battleType {
                case .Challenge:
                    return "\(initiator.screenname) challenges you"
                case .Dare:
                    return "\(initiator.screenname) dares you"
                }

            }
        }

        switch battle.battleType {
        case .Challenge:
            return "\(initiator.screenname) v \(recipient.screenname)"
        case .Dare:
            return "\(initiator.screenname) dares \(recipient.screenname)"
        }
    }

}
