//
//  Colors.swift
//  Challenge
//
//  Created by Daniel Spinosa on 7/24/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit
import DynamicColor

struct Colors {

    static let positiveGradientBackgroundColors = [
        UIColor(named: "PositiveBackgroundGradientStart")!.cgColor,
        UIColor(named: "PositiveBackgroundGradientEnd")!.cgColor
    ]

    static let negativeGradientBackgroundColors = [
        UIColor(named: "NegativeBackgroundGradientStart")!.cgColor,
        UIColor(named: "NegativeBackgroundGradientEnd")!.cgColor
    ]

    static let neutralGradientBackgroundColors = [UIColor.white.cgColor, UIColor.white.cgColor]

}
