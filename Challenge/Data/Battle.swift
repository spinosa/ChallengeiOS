//
//  Battle.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/18/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import Foundation

struct Battle: Codable {

    static func forCreate(recipient: User, description: String, type: BattleType, invitedRecipientEmail: String? = nil, invitedRecipientPhoneNumber: String? = nil) -> Battle {
        return Battle(id: "na", initiator: recipient, recipient: recipient, recipientScreenname: recipient.screenname, description: description, battleType: type, outcome: .TBD, state: .open, disputedBy: nil, disputedAt: nil, invitedRecipientEmail: invitedRecipientEmail, invitedRecipientPhoneNumber: invitedRecipientPhoneNumber, createdAt: Date(), updatedAt: Date())
    }

    let id: String

    let initiator: User
    let recipient: User?
    
    /// kludge: only used during create
    let recipientScreenname: String?

    let description: String
    let battleType: BattleType
    let outcome: Outcome
    let state: State

    let disputedBy: User?
    let disputedAt: Date?

    let invitedRecipientEmail: String?
    let invitedRecipientPhoneNumber: String?

    let createdAt: Date
    let updatedAt: Date

    enum BattleType: Int, Codable {
        case Challenge = 0,
        Dare = 1
    }

    enum Outcome: Int, Codable {
        case TBD = 1,
        initiatorWin = 2,
        initiatorLoss = 4,
        noContest = 8,
        recipientDareWin = 16,
        recipientDareLoss = 32
    }

    enum State: Int, Codable {
        case open = 1,
        cancelledByInitiator = 2,
        declinedByRecipient = 4,
        pending = 8,
        complete = 16
    }

    static let DidCreateBattle: NSNotification.Name = NSNotification.Name(rawValue: "DidCreateBattle")
    static let CreatedBattleKey = "CreatedBattle"
    static let ShowBattle: NSNotification.Name = NSNotification.Name(rawValue: "ShowBattle")
    static let BattleIdKey = "BattleId"

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

    var isDisputed: Bool {
        get {
            return state == .complete && disputedBy != nil
        }
    }

    var isActive: Bool {
        get {
            return state == .open || state == .pending
        }
    }

}

//MARK:- Webservice

/// Ruby API expects {battle: {attr1: this, attr2: that, ...}}
/// This is the simplest way I could think of to accomplish that (without complicating stuff elsewhere)
fileprivate struct  WrappedBattle: Codable {
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
    static let all    = Resource<[Battle]>(url: URL(string: "\(Endpoints.apiBase)/battles.json")!)

    /// Show a single battle
    static func show(id: String) -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(id).json")!)
    }

    //XXX TODO REFACTOR: Webservice could have an IndividuallyAddressable protocol which requires implementation like the following:
    // and Webservice delete takes an IndividuallyAddressable Resource
    func resource() -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(id).json")!)
    }

    /// Battles created by others, challenging me
    static let inbox  = Resource<[Battle]>(url: URL(string: "\(Endpoints.apiBase)/battles.json?inbox=true")!)

    /// Battles I've created, challenging another
    static let outbox = Resource<[Battle]>(url: URL(string: "\(Endpoints.apiBase)/battles.json?outbox=true")!)

    /// Battles involving me (as initiator or recipient) not yet completed (cancelled or finished)
    static let myActive = Resource<[Battle]>(url: URL(string: "\(Endpoints.apiBase)/battles.json?myActive=true")!)

    /// Battles involving me (as initiator or recipient) that are completed (cancelled or finished)
    static let myArchive = Resource<[Battle]>(url: URL(string: "\(Endpoints.apiBase)/battles.json?myArchive=true")!)

    /// Create a new Battle
    static let create = Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles.json")!, encoder: WrappedBattle.encoder)

    /// Initiator can cancel a battle while it's pending
    static func cancel(battle: Battle) -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(battle.id)/cancel.json")!)
    }
    func cancel() -> Resource<Battle> { return Battle.cancel(battle: self) }

    /// Recipient can decline a battle while it's pending
    static func decline(battle: Battle) -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(battle.id)/decline.json")!)
    }
    func decline() -> Resource<Battle> { return Battle.decline(battle: self) }

    /// Recipient can accept a battle while it's pending
    static func accept(battle: Battle) -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(battle.id)/accept.json")!)
    }
    func accept() -> Resource<Battle> { return Battle.accept(battle: self) }

    /// Recipient sets the outcome of an open battle
    static func complete(battle: Battle, outcome: Battle.Outcome) -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(battle.id)/complete.json?outcome=\(outcome.rawValue)")!)
    }
    func complete(outcome: Battle.Outcome) -> Resource<Battle> { return Battle.complete(battle: self, outcome: outcome) }

    /// Initiator can dispute a battle after it's completed
    static func dispute(battle: Battle) -> Resource<Battle> {
        return Resource<Battle>(url: URL(string: "\(Endpoints.apiBase)/battles/\(battle.id)/dispute.json")!)
    }
    func dispute() -> Resource<Battle> { return Battle.dispute(battle: self) }
}
