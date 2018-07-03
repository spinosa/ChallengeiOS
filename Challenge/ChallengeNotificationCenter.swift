//
//  ChallengeNotificationCenter.swift
//  Challenge
//
//  Created by Daniel Spinosa on 7/3/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit
import UserNotifications

class ChallengeNotificationCenter: NSObject {

    static let current = ChallengeNotificationCenter()

    private override init() {
        // Make sure our device token is up to date.
        // First-registration happens at a more appropriate time
        UNUserNotificationCenter.current().getNotificationSettings { (noteSettings) in
            //using the negative check for forward compatibility with iOS 12 provisional notificaitons
            if noteSettings.authorizationStatus != .denied && noteSettings.authorizationStatus != .notDetermined {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    public func requestAuthorization() {
        //SOMEDAY: Put up one of those pre-request messages to better explain notifications and get opt-in?
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("USER NOTIFCATIONS CAME BACK")
            print("granted? \(granted)")

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else if let error = error {
                print("error? \(error)")
            }
            else {
                //SOMEDAY: Let the user know we can't push to them
            }
        }
    }
}

extension ChallengeNotificationCenter: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        if let battleId = content.userInfo["battle_id"] {
            NotificationCenter.default.post(name: Battle.ShowBattle, object: nil, userInfo: [Battle.BattleIdKey: battleId as Any])
        }

        completionHandler()
    }
}
