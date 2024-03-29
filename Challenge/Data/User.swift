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
        return User(screenname: screenname, email: email, password: password, authorizationHeader: nil, apnsDeviceToken: nil, apnsSandboxDeviceToken: nil, phone: nil, winsTotal: -1, lossesTotal: -1, winsWhenInitiator: -1, lossesWhenInitiator: -1, winsWhenRecipient: -1, lossesWhenRecipient: -1, disputesBroughtTotal: -1, disputesBroughtAgainstTotal: -1, isRoot: false)
    }

    static func forSignIn(email: String, password: String) -> User {
        return User(screenname: "na", email: email, password: password, authorizationHeader: nil, apnsDeviceToken: nil, apnsSandboxDeviceToken: nil, phone: nil, winsTotal: -1, lossesTotal: -1, winsWhenInitiator: -1, lossesWhenInitiator: -1, winsWhenRecipient: -1, lossesWhenRecipient: -1, disputesBroughtTotal: -1, disputesBroughtAgainstTotal: -1, isRoot: false)
    }

    let screenname: String
    let email: String?

    /// kludge: only used during create
    let password: String?
    
    /// kludge: The JWT used for HTTP
    var authorizationHeader: String?

    /// Used to PATCH user on server side
    var apnsDeviceToken: String?
    var apnsSandboxDeviceToken: String?
    
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

    // rudimentary access control (enforced by API, used by client only for UI/UX modifications)
    let isRoot: Bool?

    /// ******** Current User ********
    private static let CurrentUserKey = "current_user"
    private static let EverHadCurrentUser = "ever_had_current_user"

    static let DidSetCurrentUser: NSNotification.Name = NSNotification.Name(rawValue: "DidSetCurrentUser")

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
                NotificationCenter.default.post(name: DidSetCurrentUser, object: self)
            }
        }
    }

    static var everHadCurrentUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: EverHadCurrentUser)
        }
    }

}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.screenname == rhs.screenname
    }
}

/// Ruby API expects {user: {attr1: this, attr2: that, ...}}
/// This is the simplest way I could think of to accomplish that (without complicating stuff elsewhere)
fileprivate struct  WrappedUser: Codable {
    let user: User

    static let encoder:((User) -> Data?) = { (user) -> Data? in
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        let wrappedUser = WrappedUser(user: user)
        return try? encoder.encode(wrappedUser)
    }
}

extension User {

    static let create = Resource<User>(url: URL(string: "\(Endpoints.apiBase)/users.json")!, encoder: WrappedUser.encoder)
    
    static let signIn = Resource<User>(url: URL(string: "\(Endpoints.apiBase)/users/sign_in.json")!, encoder: WrappedUser.encoder)

    static let update = Resource<User>(url: URL(string: "\(Endpoints.apiBase)/current_user.json")!, encoder: WrappedUser.encoder)

    static func searchBy(username: String) -> Resource<[User]> {
        return Resource<[User]>(url: URL(string: "\(Endpoints.apiBase)/users/search/screenname/\(username).json")!)
    }

}
