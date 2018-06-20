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
        Webservice().post(User.signIn, instance: userCreds) { user, urlResponse in
            //TODO: DRY with sign up
            if var user = user,
                let response = urlResponse as? HTTPURLResponse,
                let authHeader = response.allHeaderFields["Authorization"] as? String {
                user.authorizationHeader = authHeader
                User.currentUser = user
            }
        }
    }

    @IBAction func signUp(_ sender: Any) {
        guard !hasSignUpFormErrors() else { return }
        guard let sn = screenname.text,
            let em = email.text,
            let pw = password.text else { return }

        signUpButton.isEnabled = false

        let newUser: User = User.forCreate(screenname: sn, email: em, password: pw)
        Webservice().post(User.create, instance: newUser) { createdUser, urlResponse in
            //TOOD: DRY with sign in
            if var user = createdUser,
                let response = urlResponse as? HTTPURLResponse,
                let authHeader = response.allHeaderFields["Authorization"] as? String {
                user.authorizationHeader = authHeader
                User.currentUser = user
            }
        }
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
