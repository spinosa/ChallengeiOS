//
//  UsernameSelectionTableViewCell.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/20/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

protocol UsernameSelectionTableViewCellDelegate {
    func setUsers(_ users: [User]?, matching username: String)
}

class UsernameSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameField: UITextField!

    public var delegate: UsernameSelectionTableViewCellDelegate?

    var searchTimer: Timer? = nil

    @IBAction func usernameUpdated(_ sender: Any) {
        guard let username = usernameField.text else { return }
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [username, weak self] _ in
            self?.search(for: username)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    public func reset() {
        usernameField.text = nil
    }

    private func search(for username: String) {
        if username.count == 0 {
            self.delegate?.setUsers(nil, matching: username)
        }
        else {
            Webservice.forCurrentUser.load(User.searchBy(username: username)) { [weak self] (users) in
                self?.delegate?.setUsers(users, matching: username)
            }
        }
    }

}
