//
//  MotionViewEffect.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/19/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    /**
     This function is just to give a view a motion effect when the phone is being tilted/rotated
     */
    func applyViewMotionEffect (toView view:UIView,magnitudeX:Float, magnitudeY:Float) {
        let XMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        XMotion.minimumRelativeValue = -magnitudeX
        XMotion.maximumRelativeValue = magnitudeX
        
        let YMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        YMotion.minimumRelativeValue = -magnitudeY
        YMotion.maximumRelativeValue = magnitudeY
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [XMotion,YMotion]
        
        view.addMotionEffect(group)
        
    }
}

