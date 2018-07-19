//
//  BattleSummaryTableViewCell.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/22/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class BattleSummaryTableViewCell: UITableViewCell {

    static let ReuseIdentifier = "BattleSummaryTableViewCell"

    @IBOutlet weak var initiatorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet var allLabels: [UILabel]!

    var battle: Battle? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        allLabels.forEach { $0.text = nil }
    }

    private func updateUI() {
        guard let battle = battle, battle.recipient != nil else {
            initiatorLabel.text = nil
            headlineLabel.text = "Buggy Battle"
            contentLabel.text = "bug: no recipient"
            return
        }

        initiatorLabel.text = "@\(battle.initiator.screenname)"
        dateLabel.text = battle.lastUpdatedCopy()
        headlineLabel.text = battle.headlineCopyFromPerspectiveOf(User.currentUser)
        contentLabel.text = battle.contentCopy()
        self.backgroundColor = battle.backgroundColorFromPerspectiveOf(User.currentUser)
    }

}
