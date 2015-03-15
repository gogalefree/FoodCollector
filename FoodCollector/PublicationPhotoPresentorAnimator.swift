//
//  PublicationPhotoPresentorAnimator.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationPhotoPresentorAnimator: NSObject , UIViewControllerAnimatedTransitioning {
    
    var duration = 0.3
    var originFrame = CGRect.zeroRect //the frame of the header view

    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        
        var navigationControllerView =
        transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        var fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
       
        navigationControllerView.frame = containerView.bounds

        containerView.addSubview(navigationControllerView)
        containerView.bringSubviewToFront(navigationControllerView)
        
        UIView.animateWithDuration(duration, delay:0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: {
             
            }, completion:{_ in
                transitionContext.completeTransition(true)
        })
    }
    
    func animationEnded(transitionCompleted: Bool) {
    }

   
}
