//
//  PublicationPhotoPresentorPresentationController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationPhotoPresentorPresentationController: UIPresentationController {
    
    var dimmingView: UIView!
    
    override func presentationTransitionWillBegin() {
        
        self.prepareDimmingView()
        
        let containerView  = self.containerView
        let presentedVC    = self.presentedViewController as! UINavigationController

        containerView.insertSubview(dimmingView, atIndex: 0)
        self.dimmingView.alpha = 1
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in
            self.dimmingView.alpha = 0
            }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        self.dimmingView.removeFromSuperview()
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return parentSize
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        //final frame
        var frame = self.containerView.bounds
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        
        //handle rotation
        dimmingView.frame = containerView.bounds
        presentedView().frame = frameOfPresentedViewInContainerView()
    }
    
    func prepareDimmingView() {
        
        dimmingView = UIView(frame: presentingViewController.view.bounds)
        
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = dimmingView.bounds
        visualEffectView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        dimmingView.addSubview(visualEffectView)
        dimmingView.alpha = 0
        
    }
}
