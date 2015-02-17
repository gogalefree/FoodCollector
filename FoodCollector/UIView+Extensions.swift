//
//  UIView+Extensions.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/13/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func animateToAlphaWithSpring(duration: NSTimeInterval , alpha: CGFloat) {
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.alpha = alpha
        }, completion: nil)
    }
    
    func animateToCenterWithSpring(duration: NSTimeInterval , center: CGPoint) {
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.center = center
            }, completion: nil)
    }
    
}

extension UITabBar{
    
    func animateCenterWithSpring(duration: NSTimeInterval , center: CGPoint) {
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.center = center
            }, completion: nil)
    }
}