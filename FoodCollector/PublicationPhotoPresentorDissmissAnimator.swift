//
//  PublicationPhotoPresentorDissmissAnimator.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/13/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationPhotoPresentorDissmissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
   
    var duration = 0.3

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        
        var navigationControllerView =
        transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        
        
        containerView.addSubview(navigationControllerView)
        containerView.bringSubviewToFront(navigationControllerView)
        
        UIView.animateWithDuration(duration, delay:0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: {
                
                navigationControllerView.alpha = 0
                
            }, completion:{_ in
                transitionContext.completeTransition(true)
        })
    }
    
    func animationEnded(transitionCompleted: Bool) {
    }

}
