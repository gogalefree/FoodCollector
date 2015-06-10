//
//  FCCollectorContainerController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/25/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import UIKit

class FCCollectorContainerController: UIViewController, CollectorVCSlideDelegate {
    
    var activityCenterNavigationController: UINavigationController!
    var collectorRootNavigationController: UINavigationController!
    var activityCenterPresented = false
    var kCollectorMapVCFraction: CGFloat = 0.85
    
    var tabBarVisibleOrigin: CGPoint!
    var tabBarHiddenOrigin: CGPoint!
    var collectorMapVisibleOrigin: CGPoint!
    var collectorMapHiddenOrigin: CGPoint!
    
    var statusBarHidden: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityCenterNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("activityCenterNavController") as! UINavigationController
        
        collectorRootNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("collectorRootNavController") as! UINavigationController
        
        self.addChildViewController(activityCenterNavigationController)
        activityCenterNavigationController.view.frame = self.view.bounds
        activityCenterNavigationController.view.frame.size.width = kCollectorMapVCFraction * CGRectGetWidth(self.view.bounds)
        self.view.addSubview(self.activityCenterNavigationController.view)
        self.activityCenterNavigationController.didMoveToParentViewController(self)
        
        self.addChildViewController(self.collectorRootNavigationController)
        collectorRootNavigationController.view.frame = self.view.bounds
        self.view.addSubview(collectorRootNavigationController.view)
        collectorRootNavigationController.didMoveToParentViewController(self)
        
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCCollectorRootVC
        collectorRootVC.delegate = self
        
        self.definePointsWithRect(self.view.bounds)
        
    }
    
    func collectorVCWillSlide() {
        if !activityCenterPresented { showActivityCenter() }
        else { hideActivityCenter() }
    }
    
    func showActivityCenter() {
        
        //reload data in activity center
        activityCenterPresented = true
        let activityCenterVC = activityCenterNavigationController.viewControllers[0] as! FCActivityCenterTVC
        activityCenterVC.reload()
        
        //inform collector root vc that activity center is presented
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCCollectorRootVC
        collectorRootVC.isPresentingActivityCenter = true
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.collectorRootNavigationController.view.frame.origin = self.collectorMapHiddenOrigin
            self.tabBarController?.tabBar.frame.origin = self.tabBarHiddenOrigin
            
            }) { (completion) -> Void in
                activityCenterVC.displaySections()
                self.showStatusBar(false)
        }
    }
    
    func hideActivityCenter() {
        
        activityCenterPresented = false
        
        //inform collector root vc that activity center is presented
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCCollectorRootVC
        collectorRootVC.isPresentingActivityCenter = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.collectorRootNavigationController.view.center = self.view.center
            self.tabBarController?.tabBar.frame.origin = self.tabBarVisibleOrigin
            }){ (completion) -> Void in
                self.showStatusBar(true)
        }
    }
    
    func definePointsWithRect(containerBounds: CGRect) {
        
        let collectorMapHiddenOriginX = ceil(containerBounds.width * kCollectorMapVCFraction)
        let collectorMapHiddenOriginy = CGRectGetMinY(containerBounds)
        collectorMapHiddenOrigin = CGPointMake(collectorMapHiddenOriginX, collectorMapHiddenOriginy)
        collectorMapVisibleOrigin = containerBounds.origin
        
        tabBarVisibleOrigin = CGPointMake(0, containerBounds.height - self.tabBarController!.tabBar.frame.size.height)
        
        let tabBarHiddenOriginX = collectorMapHiddenOriginX
        let tabBarHiddenOriginY = containerBounds.size.height - self.tabBarController!.tabBar.frame.size.height
        tabBarHiddenOrigin = CGPointMake(tabBarHiddenOriginX, tabBarHiddenOriginY)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let boundsRect = CGRectMake(0, 0, size.width, size.height)
        self.definePointsWithRect(boundsRect)
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            
            self.activityCenterNavigationController.view.frame = CGRectMake(0, 0, size.width, size.height)
            self.activityCenterNavigationController.view.frame.size.width = self.kCollectorMapVCFraction * size.width
            
            if self.activityCenterPresented {
                self.showActivityCenter()
            }
            
            }, completion: { (context) -> Void in})
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    func showStatusBar(show: Bool) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.statusBarHidden = !show
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
