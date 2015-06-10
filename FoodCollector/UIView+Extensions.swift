//
//  UIView+Extensions.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/13/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func animateToAlphaWithSpring(duration: NSTimeInterval , alpha: CGFloat) {
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.alpha = alpha
        }, completion: nil)
    }
    
    func animateToCenterWithSpring(duration: NSTimeInterval , center: CGPoint, completion: (completion:Bool)->()) {
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.center = center
            }, completion: completion)
    }
    
    func animateToYWithSpring(duration: NSTimeInterval , Yvalue: CGFloat ,completion: (completion:Bool)->()) {
        
        var newOrigin = self.frame.origin
        newOrigin.y = Yvalue
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.frame.origin = newOrigin
            self.superview?.layoutIfNeeded()
            }, completion: completion)
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

extension UITabBar{
    
    func animateCenterWithSpring(duration: NSTimeInterval , center: CGPoint) {
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.center = center
            }, completion: nil)
    }
}