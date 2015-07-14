//
//  FCPublicationReportsVCAnimator.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/19/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationReportsVCAnimator: NSObject , UIViewControllerAnimatedTransitioning{
    
    var originFrame: CGRect!
    var duration = 0.4
   
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        
        let navigationControllerView =
        transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let navigationController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UINavigationController
        
        let tableViewController = navigationController.viewControllers[0] as! FCPublicationReportsTVC
        
        let tableView = tableViewController.tableView
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        

        navigationControllerView.frame = containerView.bounds
        
        let xScaleFactor = containerView.bounds.size.width / originFrame.width
        let yScaleFactor = containerView.bounds.size.height / originFrame.height
        
        let startingScale = CGAffineTransformMakeScale(1 / xScaleFactor, 1 / yScaleFactor)

        tableView.transform = startingScale

        
        containerView.addSubview(navigationControllerView)
        containerView.bringSubviewToFront(navigationControllerView)
        
        
        UIView.animateWithDuration(duration, delay:0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: {
                
              
                tableView.transform = CGAffineTransformIdentity
                tableView.frame = navigationControllerView.bounds
                
            }, completion:{_ in
                transitionContext.completeTransition(true)
        })
    }

}
