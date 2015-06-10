//
//  FCPublicationReportsDismissAnimator.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/20/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import UIKit

class FCPublicationReportsDismissAnimator: NSObject , UIViewControllerAnimatedTransitioning{
    
    var destinationRect: CGRect!
    var duration = 0.4

    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        
        let navigationControllerView =
        transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let navigationController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController
        
        let tableViewController = navigationController.viewControllers[0] as! FCPublicationReportsTVC
        
        let tableView = tableViewController.tableView
        
        
        let xScaleFactor =   destinationRect.width / containerView.bounds.size.width
        let yScaleFactor = destinationRect.height / containerView.bounds.size.height
        
        let finalScale = CGAffineTransformMakeScale(xScaleFactor,  yScaleFactor)
        
        
        
        containerView.addSubview(navigationControllerView)
        containerView.bringSubviewToFront(navigationControllerView)
        
        
        UIView.animateWithDuration(duration, delay:0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: {
                
                tableView.transform = finalScale
                tableView.frame = self.destinationRect
                navigationControllerView.alpha = 0
                
            }, completion:{_ in
                
                
                transitionContext.completeTransition(true)
        })
    }
    

   
}
