//
//  SignInViewController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/19/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var screenname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var haveAnAccountButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if User.everHadCurrentUser {
            showSignIn()
        }
        else {
            showSignUp()
        }
    }

    @IBAction func showSignIn() {
        screenname.isHidden = true
        haveAnAccountButton.isHidden = true
        signUpButton.isHidden = true

        signInButton.isHidden = false
        signInButton.isEnabled = true
        dontHaveAccountButton.isHidden = false
    }

    @IBAction func showSignUp() {
        screenname.isHidden = false
        haveAnAccountButton.isHidden = false
        signUpButton.isHidden = false
        signUpButton.isEnabled = true

        signInButton.isHidden = true
        dontHaveAccountButton.isHidden = true
    }

    @IBAction func signIn(_ sender: Any) {
        guard !hasSignInFormErrors() else { return }
        guard let em = email.text,
            let pw = password.text else { return }

        signInButton.isEnabled = false

        let userCreds: User = User.forSignIn(email: em, password: pw)

        Webservice().post(User.signIn, instance: userCreds, success: { (user, response) in
            if !self.setCurrentUser(from: user, response: response) {
                self.present(error: nil, withTitle: "Problem Signing In")
            }
        }) { (error) in
            self.present(error: error, withTitle: "Problem Signing In")
        }
    }

    @IBAction func signUp(_ sender: Any) {
        guard !hasSignUpFormErrors() else { return }
        guard let sn = screenname.text,
            let em = email.text,
            let pw = password.text else { return }

        signUpButton.isEnabled = false

        let newUser: User = User.forCreate(screenname: sn, email: em, password: pw)
        Webservice().post(User.create, instance: newUser, success: { (createdUser, response) in
            if !self.setCurrentUser(from: createdUser, response: response) {
                self.present(error: nil, withTitle: "Problem Signing Up")
            }
        }) { (error) in
            self.present(error: error, withTitle: "Problem Signing Up")
        }
    }

    private func setCurrentUser(from returnedUser: User, response: HTTPURLResponse) -> Bool {
        guard let authHeader = response.allHeaderFields["Authorization"] as? String else {
            assertionFailure("Expected Authorization Header in response")
            return false
        }
        var user = returnedUser
        user.authorizationHeader = authHeader
        User.currentUser = user
        return true
    }

    private func present(error: ErrorResponse?, withTitle title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: self.message(from: error), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Let's Try Again", style: .default, handler: nil))
            self.present(alert, animated: true, completion: {
                self.signInButton.isEnabled = true
                self.signUpButton.isEnabled = true
            })
        }
    }

    private func message(from error: ErrorResponse?) -> String {
        if let error = error {
            if let singleMessage = error.error {
                return singleMessage
            }
            else if let errors = error.errors {
                return errors.map({ "\($0.capitalized) \($1.joined(separator: ", "))." }).joined(separator: "\n\n")
            }
        }

        return "Something quite unexpected went wrong."
    }

    private func hasSignUpFormErrors() -> Bool {
        //TODO: Check for problematic fields and highlight them appropriately
        return false
    }

    private func hasSignInFormErrors() -> Bool {
        //TODO: Check for problematic fields and highlight them appropriately
        return false
    }

}
