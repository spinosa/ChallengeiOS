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

        NotificationCenter.default.addObserver(forName: User.DidSetCurrentUser, object: nil, queue: OperationQueue.main) { (_) in
            self.dismiss(animated: true, completion: nil)
        }

        NotificationCenter.default.addObserver(forName: Battle.DidCreateBattle, object: nil, queue: OperationQueue.main) { note in
            if let battle = note.userInfo?[Battle.CreatedBattleKey] as? Battle {
                self.showCreatedBattle(battle)
            }
        }

        NotificationCenter.default.addObserver(forName: Battle.ShowBattle, object: nil, queue: OperationQueue.main) { note in
            if let battleId = note.userInfo?[Battle.BattleIdKey] as? String {
                self.showBattle(id: battleId)
            }
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

    private func showCreatedBattle(_ battle: Battle) {
        if let (myBattlesVC, myBattlesIdx) = viewController(type: MyBattlesViewController.self) {
            self.selectedIndex = myBattlesIdx
            myBattlesVC.navigationController?.popToRootViewController(animated: false)
            myBattlesVC.showCreatedBattle(battle)
        }
    }

    private func showBattle(id battleId: String) {
        if let (myBattlesVC, myBattlesIdx) = viewController(type: MyBattlesViewController.self) {
            self.selectedIndex = myBattlesIdx
            myBattlesVC.navigationController?.popToRootViewController(animated: false)
            myBattlesVC.showBattle(id: battleId)
        }
    }

    private func viewController<T>(type: T.Type) -> (T, Int)? {
        if let idx = self.viewControllers?.index(where: { (vc) -> Bool in
            return (vc is T) ||
                (vc is UINavigationController && (vc as! UINavigationController).viewControllers.first is T)
        }) {
            if let vc = self.viewControllers?[idx] as? T {
                return (vc, idx)
            }
            else if let navWrapper = self.viewControllers?[idx] as? UINavigationController,
                let vc = navWrapper.viewControllers.first as? T {
                return (vc, idx)
            }
        }
        return nil
    }
}
