//
//  Battle.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/18/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import Foundation

struct Battle: Codable {

    static func forCreate(recipient: User, description: String, invitedRecipientEmail: String? = nil, invitedRecipientPhoneNumber: String? = nil) -> Battle {
        return Battle(id: "na", initiator: recipient, recipient: recipient, recipientScreenname: recipient.screenname, description: description, outcome: .TBD, state: .open, disputedBy: nil, disputedAt: nil, invitedRecipientEmail: invitedRecipientEmail, invitedRecipientPhoneNumber: invitedRecipientPhoneNumber, createdAt: Date(), updatedAt: Date())
    }

    let id: String

    let initiator: User
    let recipient: User?
    
    /// kludge: only used during create
    let recipientScreenname: String?

    let description: String
    let outcome: Outcome
    let state: State

    let disputedBy: User?
    let disputedAt: Date?

    let invitedRecipientEmail: String?
    let invitedRecipientPhoneNumber: String?

    let createdAt: Date
    let updatedAt: Date

    enum Outcome: Int, Codable {
        case TBD = 1,
        initiatorWin = 2,
        initiatorLoss = 4,
        noContest = 8
    }

    enum State: Int, Codable {
        case open = 1,
        cancelledByInitiator = 2,
        declinedByRecipient = 4,
        pending = 8,
        complete = 16
    }

    static let DidCreateBattle: NSNotification.Name = NSNotification.Name(rawValue: "DidCreateBattle")
    static let CreatedBattleKey: String = "CreatedBattle"

    //MARK:-
    //convenience

    var winner: User? {
        get {
            if state == .complete {
                if outcome == .initiatorWin { return initiator }
                if outcome == .initiatorLoss { return recipient }
            }
            return nil
        }
    }

}

//MARK:- Webservice

/// Ruby API expects {battle: {attr1: this, attr2: that, ...}}
/// This is the simplest way I could think of to accomplish that (without complicating stuff elsewhere)
struct  WrappedBattle: Codable {
    let battle: Battle

    static let encoder:((Battle) -> Data?) = { (battle) -> Data? in
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        let wrappedBattle = WrappedBattle(battle: battle)
        return try? encoder.encode(wrappedBattle)
    }
}

extension Battle {

    /// All publicly accessible Battles
    static let all    = Resource<[Battle]>(url: URL(string: "http://localhost:3000/battles.json")!)

    /// Battles created by others, challenging me
    static let inbox  = Resource<[Battle]>(url: URL(string: "http://localhost:3000/battles.json?inbox=true")!)

    /// Battles I've created, challenging another
    static let outbox = Resource<[Battle]>(url: URL(string: "http://localhost:3000/battles.json?outbox=true")!)

    /// Battles involving me (as initiator or recipient) not yet completed (cancelled or finished)
    static let myActive = Resource<[Battle]>(url: URL(string: "http://localhost:3000/battles.json?myActive=true")!)

    /// Battles involving me (as initiator or recipient) that are completed (cancelled or finished)
    static let myArchive = Resource<[Battle]>(url: URL(string: "http://localhost:3000/battles.json?myArchive=true")!)

    /// Create a new Battle
    static let create = Resource<Battle>(url: URL(string: "http://localhost:3000/battles.json")!, encoder: WrappedBattle.encoder)
}
