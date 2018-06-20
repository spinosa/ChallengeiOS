//
//  Battle.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/18/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import Foundation

struct Battle: Codable {

    let id: String

    let initiator: User
    let recipient: User?

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
        initiatorWin,
        initiatorLoss,
        noContest
    }

    enum State: Int, Codable {
        case open = 1,
        cancelledByInitiator,
        declinedByRecipient,
        pending,
        complete
    }

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

extension Battle {
    static let all = Resource<[Battle]>(url: URL(string: "http://localhost:3000/battles.json")!)
}
