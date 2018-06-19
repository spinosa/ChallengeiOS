//
//  User.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/18/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import Foundation

struct User: Codable {

    static func forCreate(screenname: String, email: String, password: String) -> User {
        return User(screenname: screenname, email: email, password: password, authorizationHeader: nil, phone: nil, winsTotal: -1, lossesTotal: -1, winsWhenInitiator: -1, lossesWhenInitiator: -1, winsWhenRecipient: -1, lossesWhenRecipient: -1, disputesBroughtTotal: -1, disputesBroughtAgainstTotal: -1)
    }

    let screenname: String
    let email: String?
    /// only used during create
    let password: String?
    /// The JWT used for HTTP
    var authorizationHeader: String?
    
    let phone: String?
    let phoneConfirmed: Bool = false

    let winsTotal: Int
    let lossesTotal: Int

    let winsWhenInitiator: Int
    let lossesWhenInitiator: Int

    let winsWhenRecipient: Int
    let lossesWhenRecipient: Int

    let disputesBroughtTotal: Int
    let disputesBroughtAgainstTotal: Int

    /// ******** Current User ********
    private static let CurrentUserKey = "current_user"
    private static let EverHadCurrentUser = "ever_had_current_user"

    static var currentUser: User? {
        get {
            if let data = UserDefaults.standard.object(forKey: CurrentUserKey) as? Data,
                let u = try? PropertyListDecoder().decode(User.self, from: data) {
                return u
            }
            return nil
        }
        set {
            UserDefaults.standard.removeObject(forKey: CurrentUserKey)
            if let u = newValue {
                UserDefaults.standard.set(try! PropertyListEncoder().encode(u), forKey: CurrentUserKey)
                UserDefaults.standard.set(true, forKey: EverHadCurrentUser)
                NotificationCenter.default.post(name: Notification.Name.DidSetCurrentUser, object: self)
            }
        }
    }

    static var everHadCurrentUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: EverHadCurrentUser)
        }
    }

}

/// Ruby API expects {user: {attr1: this, attr2: that, ...}}
/// This is the simplest way I could think of to accomplish that (without complicating stuff elsewhere)
struct  WrappedUser: Codable {
    let user: User
}

extension User {
    static let oldCreate = Resource<User>(url: URL(string: "http://localhost:3000/users.json")!)
    static let create = Resource<User>(url: URL(string: "http://localhost:3000/users.json")!, parser: nil) { (user) -> Data? in
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        let wrappedUser = WrappedUser(user: user)
        return try? encoder.encode(wrappedUser)
    }
}

extension Notification.Name {
    static let DidSetCurrentUser = Notification.Name("DidSetCurrentUer")
}

