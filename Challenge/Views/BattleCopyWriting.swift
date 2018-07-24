//
//  BattleCopyWriting.swift
//  Challenge
//
//  Created by Daniel Spinosa on 7/19/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//
//  Not sure how I feel about this UI copy writing helper being an extension on Battle.
//  It certainly is convenient.  Looks pretty good at the call site.
//  I very much like how discoverable this API is.
//  But it smells a bit, adding this View code onto a Model.
//  Maybe I'll refactor this into something like BattleCopy.headline(_ battle: Battle, fromPerspectiveOf user: User)

import UIKit

//MARK: - Last Update copy writing
extension Battle {
    
    func lastUpdatedCopy() -> String {
        let componentsOfTimeAgo = Calendar.current.dateComponents([.minute, .hour, .day, .month], from: self.updatedAt, to: Date())
        // 6+ months ago
        if let months = componentsOfTimeAgo.month, months > 6 {
            return DateFormatter.monthDayYearForUI.string(from: self.updatedAt)
        }

        // < 24 hours ago
        if let days = componentsOfTimeAgo.day, days < 1,
            let hours = componentsOfTimeAgo.hour,
            let minutes = componentsOfTimeAgo.minute {
            switch hours {
            case 0:
                switch minutes {
                case 0..<5:
                    return "just now"
                default:
                    return "\(minutes) minutes ago"
                }
            case 1:
                return "1 hour ago"
            default:
                return "\(hours) hours ago"
            }
        }

        // 1 day ... 6 months
        return DateFormatter.monthDayForUI.string(from: self.updatedAt)

    }
}

//MARK: - Headline copy writing
extension Battle {
    func headlineCopyFromPerspectiveOf(_ viewingUser: User?) -> String {
        if viewingUser != nil {
            if viewingUser == self.initiator {
                return initiatorsPerspectiveHeadlineCopy()
            }
            if viewingUser == self.recipient {
                return recipientsPerspectiveHeadlineCopy()
            }
        }
        return outsiderHeadlineCopy()
    }

    fileprivate func initiatorsPerspectiveHeadlineCopy() -> String {
        guard let recipient = self.recipient else { return "HEADLINE WRITER IS ON VACATION" }

        switch self.state {

        case .pending:
            fallthrough
        case .open:
            switch self.battleType {
            case .Challenge:
                return "You challenge @\(recipient.screenname)"
            case .Dare:
                return "You dare @\(recipient.screenname)"
            }

        case .cancelledByInitiator:
            switch self.battleType {
            case .Challenge:
                return "You withdrew challenge of @\(recipient.screenname)"
            case .Dare:
                return "You withdrew dare of @\(recipient.screenname)"
            }

        case .declinedByRecipient:
            switch self.battleType {
            case .Challenge:
                return "@\(recipient.screenname) declined your challenge"
            case .Dare:
                return "@\(recipient.screenname) declined your dare"
            }

        case .complete:
            switch self.outcome {
            case .TBD:
                assertionFailure("Complete Battle should not be in TBD state")
                return "HEADLINE WRITER CALLED IN SICK"
            case .initiatorWin:
                return "You defeted @\(recipient.screenname)"
            case .initiatorLoss:
                return "@\(recipient.screenname) defeated you"
            case .noContest:
                return "Your challenge of @\(recipient.screenname) ended in no contest"
            case .recipientDareWin:
                return "@\(recipient.screenname) did it"
            case .recipientDareLoss:
                return "@\(recipient.screenname) did not do it"
            }
        }
    }

    fileprivate func recipientsPerspectiveHeadlineCopy() -> String {
        guard self.recipient != nil else { return "HEADLINE WRITER IS ON VACATION" }

        switch self.state {

        case .pending:
            fallthrough
        case .open:
            switch self.battleType {
            case .Challenge:
                return "@\(initiator.screenname) challenges you"
            case .Dare:
                return "@\(initiator.screenname) dares you"
            }

        case .cancelledByInitiator:
            switch self.battleType {
            case .Challenge:
                return "@\(initiator.screenname) withdrew their challenge of you"
            case .Dare:
                return "@\(initiator.screenname) withdrew their dare of you"
            }

        case .declinedByRecipient:
            switch self.battleType {
            case .Challenge:
                return "You declined the challenge from @\(initiator.screenname)"
            case .Dare:
                return "You declined the dare from @\(initiator.screenname)"
            }

        case .complete:
            switch self.outcome {
            case .TBD:
                assertionFailure("Complete Battle should not be in TBD state")
                return "HEADLINE WRITER CALLED IN SICK"
            case .initiatorWin:
                return "@\(initiator.screenname) defeted you"
            case .initiatorLoss:
                return "You defeated @\(initiator.screenname)"
            case .noContest:
                return "@\(initiator.screenname) challenge of you ends in no contest"
            case .recipientDareWin:
                return "You did it"
            case .recipientDareLoss:
                return "You did not do it"
            }
        }
    }

    fileprivate func outsiderHeadlineCopy() -> String {
        guard let recipient = self.recipient else { return "HEADLINE WRITER IS ON VACATION" }

        switch self.state {

        case .pending:
            fallthrough
        case .open:
            switch self.battleType {
            case .Challenge:
                return "@\(initiator.screenname) challenges @\(recipient.screenname)"
            case .Dare:
                return "@\(initiator.screenname) dares @\(recipient.screenname)"
            }

        case .cancelledByInitiator:
            switch self.battleType {
            case .Challenge:
                return "@\(initiator.screenname) withdrew challenge of @\(recipient.screenname)"
            case .Dare:
                return "@\(initiator.screenname) withdrew dare of @\(recipient.screenname)"
            }

        case .declinedByRecipient:
            switch self.battleType {
            case .Challenge:
                return "@\(recipient.screenname) declined challenge from @\(initiator.screenname)"
            case .Dare:
                return "@\(recipient.screenname) declined dare from @\(initiator.screenname)"
            }

        case .complete:
            switch self.outcome {
            case .TBD:
                assertionFailure("Complete Battle should not be in TBD state")
                return "HEADLINE WRITER CALLED IN SICK"
            case .initiatorWin:
                return "@\(initiator.screenname) defeted @\(recipient.screenname)"
            case .initiatorLoss:
                return "@\(recipient.screenname) defeated @\(initiator.screenname)"
            case .noContest:
                return "@\(initiator.screenname) v @\(recipient.screenname) ends in no contest"
            case .recipientDareWin:
                return "@\(recipient.screenname) did it"
            case .recipientDareLoss:
                return "@\(recipient.screenname) did not do it"
            }
        }
    }

}

//MARK: - Content copy
extension Battle {
    func contentCopy() -> String {
        return self.description
    }
}

//MARK: - Background color
// it's kinda like copy
//TODO: replace GREEN -> positive color
//              RED -> negative color
//              WHITE - > neurtral color
extension Battle {
    func backgroundColorFromPerspectiveOf(_ viewingUser: User?) -> UIColor {
        switch self.battleType {
        case .Challenge:
            if viewingUser != nil {
                if viewingUser == self.initiator {
                    return initiatorsPerspectiveChallengeBackgroundColor()
                }
                if viewingUser == self.recipient {
                    return recipientsPerspectiveChallengeBackgroundColor()
                }
            }
            return UIColor.white
        case .Dare:
            return backgroundColorForDare()
        }
    }

    fileprivate func initiatorsPerspectiveChallengeBackgroundColor() -> UIColor {
        switch self.outcome {
        case .initiatorWin:
            return UIColor.green
        case .initiatorLoss:
            return UIColor.red
        default:
            return UIColor.white
        }
    }

    fileprivate func recipientsPerspectiveChallengeBackgroundColor() -> UIColor {
        switch self.outcome {
        case .initiatorWin:
            return UIColor.red
        case .initiatorLoss:
            return UIColor.green
        default:
            return UIColor.white
        }
    }

    fileprivate func backgroundColorForDare() -> UIColor {
        switch self.outcome {
        case .recipientDareWin:
            return UIColor.green
        case .recipientDareLoss:
            return UIColor.red
        default:
            return UIColor.white
        }
    }
}

