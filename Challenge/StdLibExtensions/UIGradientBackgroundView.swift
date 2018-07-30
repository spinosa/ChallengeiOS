//
//  UIGradientBackgroundView.swift
//  Challenge
//
//  Created by Daniel Spinosa on 7/24/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import UIKit

class UIGradientBackgroundView: UIView {
    override class var layerClass : AnyClass {
        return CAGradientLayer.self}

    var gradientLayer: CAGradientLayer {
        get {
            return layer as! CAGradientLayer
        }
    }
}
