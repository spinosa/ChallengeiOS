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

    override func viewDidLoad() {
        super.viewDidLoad()

        if User.everHadCurrentUser {
            showSignIn()
        }
        else {
            showSignUp()
        }
    }

    func showSignIn() {
        //TODO
    }

    func showSignUp() {
        //TODO
        signUpButton.isEnabled = true
    }

    @IBAction func signUp(_ sender: Any) {
        guard !hasFormErrors() else { return }
        guard let sn = screenname.text,
            let em = email.text,
            let pw = password.text else { return }

        signUpButton.isEnabled = false

        let newUser: User = User.forCreate(screenname: sn, email: em, password: pw)
        Webservice().post(User.create, instance: newUser) { createdUser, urlResponse in
            if var user = createdUser {
                print("CREATED A USER!")
                print(user)
                if let response = urlResponse as? HTTPURLResponse {
                    print("Headers: \(response.allHeaderFields)")
                    if let authHeader = response.allHeaderFields["Authorization"] as? String {
                        print("GOT JWT: \(authHeader)")
                        user.authorizationHeader = authHeader
                        User.currentUser = user
                    }
                }
            }

        }
    }

    private func hasFormErrors() -> Bool {
        //TODO: Check for problematic fields and highlight them appropriately
        return false
    }

}
