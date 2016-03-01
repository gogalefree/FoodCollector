//
//  FCPublicationReportsPresentationController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/19/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationReportsPresentationController: UIPresentationController {
    
    var dimmingView: UIView!
    
    override func presentationTransitionWillBegin() {

    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }

    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in

            }, completion: nil)
    }
    

    
    override func presentationTransitionDidEnd(completed: Bool) {

    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return parentSize
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        //final frame
        let frame = self.containerView!.bounds
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        
        //handle rotation

        presentedView()!.frame = frameOfPresentedViewInContainerView()
    }
    
    func prepareDimmingView() {
        
        dimmingView = UIView(frame: containerView!.bounds)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = dimmingView.bounds
        visualEffectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        dimmingView.addSubview(visualEffectView)
        dimmingView.alpha = 0
    }
   
}
