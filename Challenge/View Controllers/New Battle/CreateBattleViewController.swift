//
//  CreateBattleViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/20/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class CreateBattleViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var createChallengeButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    var descriptionPlaceholderLabel : UILabel!

    public var opponent: User? {
        didSet {
            if let o = opponent {
                self.title = "You v \(o.screenname)"
            } else {
                self.title = "Challenge"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDescriptionPlaceholderLabel()
        descriptionTextView.becomeFirstResponder()
    }

    @IBAction func createChallenge(_ sender: Any) {
        guard !hasFormErrors() else { return }
        guard let description = descriptionTextView.text, let opponent = opponent else { return }

        createChallengeButton.isEnabled = false

        let newBattle = Battle.forCreate(recipient: opponent, description: description)

        Webservice.forCurrentUser.post(Battle.create, instance: newBattle) { [weak self] (battle, _) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Battle.DidCreateBattle, object: nil, userInfo: [Battle.CreatedBattleKey: battle as Any])
                self?.reset()
                self?.navigationController?.popToRootViewController(animated: false)
            }
        }
    }

    private func reset() {
        self.createChallengeButton.isEnabled = true
        self.opponent = nil
    }

    private func hasFormErrors() -> Bool {
        //TODO check and highlight
        return false
    }

    private func setupDescriptionPlaceholderLabel() {
        descriptionPlaceholderLabel = UILabel()
        descriptionPlaceholderLabel.text = "What's the challenge?"
        descriptionPlaceholderLabel.font = UIFont.italicSystemFont(ofSize: (descriptionTextView.font?.pointSize)!)
        descriptionPlaceholderLabel.sizeToFit()
        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        descriptionPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionTextView.font?.pointSize)! / 2)
        descriptionPlaceholderLabel.textColor = UIColor.lightGray
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }

    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }
}
