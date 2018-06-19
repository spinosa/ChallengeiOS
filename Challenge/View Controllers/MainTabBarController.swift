//
//  MainTabBarController.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/19/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: Notification.Name.DidSetCurrentUser, object: nil, queue: OperationQueue.main) { (note) in
            self.dismiss(animated: true, completion: {
                //TODO: Load stuff, show first tab, etc.
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if User.currentUser == nil {
            presentSignIn()
        }
    }

    private func presentSignIn() {
        let signInVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInVC")
        present(signInVC, animated: true, completion: nil)
    }
}
