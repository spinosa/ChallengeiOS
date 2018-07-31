//
//  CreateBattleViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/20/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit
import UserNotifications

class CreateBattleViewController: UIViewController {


    @IBOutlet weak var buttonsContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var buttonsScrollView: UIScrollView!
    @IBOutlet weak var buttonsPageControl: UIPageControl!
    @IBOutlet weak var createChallengeButton: UIButton!
    @IBOutlet weak var createDareButton: UIButton!
    @IBOutlet var createButtons: [UIButton]!

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

        createButtons.forEach { button in
            button.setBackgroundImage(UIImage(color: UIColor.lightGray), for: .disabled)
        }

        configurePaging()
        configureKeyboardMovementSync()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func createChallenge(_ sender: Any) {
        createBattle(type: .Challenge)
    }

    @IBAction func createDare(_ sender: Any) {
        createBattle(type: .Dare)
    }

    private func createBattle(type: Battle.BattleType) {
        guard !hasFormErrors() else { return }
        guard let description = descriptionTextView.text, let opponent = opponent else { return }

        createButtons.forEach { $0.isEnabled  = false }

        let newBattle = Battle.forCreate(recipient: opponent, description: description, type: type)

        Webservice.forCurrentUser.post(Battle.create, instance: newBattle, success: { (battle, _) in
            DispatchQueue.main.async {
                self.requestPushNotifications()

                NotificationCenter.default.post(name: Battle.DidCreateBattle, object: nil, userInfo: [Battle.CreatedBattleKey: battle as Any])
                self.reset()
                self.navigationController?.popToRootViewController(animated: false)
            }
        }) { (error) in
            //TODO: present error
        }
    }

    private func reset() {
        self.createButtons.forEach { $0.isEnabled = false }
        self.opponent = nil
    }

    private func hasFormErrors() -> Bool {
        return descriptionTextView.text.count < 3
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

    private func requestPushNotifications() {
        ChallengeNotificationCenter.current.requestAuthorization()
    }

    //MARK: - Keyboard position synchronization

    private func configureKeyboardMovementSync() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: OperationQueue.main) { note in
            guard let isLocal = note.userInfo?[UIKeyboardIsLocalUserInfoKey] as? Bool, isLocal else { return }
            if let animationCurve = note.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
                let animationDuration = note.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                //let frameBegin = note.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
                let frameEnd = note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {

                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: Int(truncating: animationCurve))!)
                UIView.setAnimationDuration(TimeInterval(truncating: animationDuration))
                UIView.setAnimationBeginsFromCurrentState(true)
                self.buttonsContainerViewBottomConstraint.constant = -frameEnd.minY
                self.view.layoutIfNeeded()
                UIView.commitAnimations()
            }
        }
    }

    //MARK: - Paging create buttons
    func configurePaging() {

        buttonsScrollView.isPagingEnabled = true
        buttonsScrollView.delegate = self
    }

    private func scrolledButtonsTo(_ page: Int) {
        buttonsPageControl.currentPage = page
        if createButtons.count >= page {
            buttonsPageControl.currentPageIndicatorTintColor = createButtons[page].backgroundColor
        }
    }
}

extension CreateBattleViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == buttonsScrollView else { return }
        let page = (scrollView.contentOffset.x / scrollView.frame.width).rounded()
        scrolledButtonsTo(Int(page))
    }

}

//MARK: - UITextViewDelegate for description

extension CreateBattleViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
        let formValid = !hasFormErrors()
        createButtons.forEach { $0.isEnabled = formValid }
    }

}
