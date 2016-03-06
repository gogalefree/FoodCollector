//
//  FCCollectorContainerController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/25/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCCollectorContainerController: UIViewController, CollectorVCSlideDelegate, FCOnSpotPublicationReportDelegate {
    
    @IBOutlet weak var mapNavigationControllerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapNavigationControllerTrailingConstraint: NSLayoutConstraint!

    let kCollectorMapVCFraction : CGFloat = 0.85
    let kConstraintsTotalPadding: CGFloat = 20
    let kViewsTotalPaddind      : CGFloat = 16
    
    var activityCenterNavigationController: UINavigationController!
    var collectorRootNavigationController: UINavigationController!
    var activityCenterPresented = false
    

    var collectorMapVisibleOrigin: CGPoint!
    var collectorMapHiddenOrigin: CGPoint!
    
    var statusBarHidden: Bool = false
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveOnSpotLocalNotification:", name: kDidArriveOnSpotNotification, object: nil)
        
        activityCenterNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("activityCenterNavController") as! UINavigationController
        
        self.addChildViewController(activityCenterNavigationController)
        activityCenterNavigationController.view.frame = self.view.bounds
        
        self.view.addSubview(self.activityCenterNavigationController.view)
        self.activityCenterNavigationController.didMoveToParentViewController(self)
        self.view.sendSubviewToBack(self.activityCenterNavigationController.view)
        
      
        for vc in self.childViewControllers {
            if vc is CollectorMapVCNavController {
                collectorRootNavigationController = vc as? UINavigationController
                break
            }
        }
        
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCCollectorRootVC
        collectorRootVC.delegate = self
        
        self.definePointsWithRect(self.view.bounds)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        presentLoginIfNeeded()
    }
    
    func presentLoginIfNeeded() {
       
        if !User.sharedInstance.userIsLoggedIn {
            let loginSB = UIStoryboard(name: "Login", bundle: nil)
            let loginVC = loginSB.instantiateInitialViewController() as! UINavigationController
            self.presentViewController(loginVC, animated: true, completion: nil)
        }   
    }
    
    func collectorVCWillSlide() {
        if !activityCenterPresented { showActivityCenter() }
        else { hideActivityCenter() }
    }
    
    func showActivityCenter() {
        
        ///reload data in activity center
        activityCenterPresented = true
        //let activityCenterVC = activityCenterNavigationController.viewControllers[0] as! ActivityCenterVC
        //activityCenterVC.reload()
        
        //inform collector root vc that activity center is presented
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCCollectorRootVC
        collectorRootVC.isPresentingActivityCenter = true
        self.mapNavigationControllerLeadingConstraint.constant = self.collectorMapHiddenOrigin.x - kConstraintsTotalPadding
        self.mapNavigationControllerTrailingConstraint.constant = -(self.collectorMapHiddenOrigin.x - kConstraintsTotalPadding)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            
            self.view.layoutIfNeeded()
    
            }) { (completion) -> Void in}
    }
    
    func hideActivityCenter() {
        
        activityCenterPresented = false
        
        //inform collector root vc that activity center is presented
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCCollectorRootVC
        collectorRootVC.isPresentingActivityCenter = false
        
        self.mapNavigationControllerLeadingConstraint.constant = -kConstraintsTotalPadding
        self.mapNavigationControllerTrailingConstraint.constant = -kConstraintsTotalPadding
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            
            self.view.layoutIfNeeded()
            
            }){ (completion) -> Void in
        }
    }
    
   
    func definePointsWithRect(containerBounds: CGRect) {
        
        let collectorMapHiddenOriginX = ceil(containerBounds.width * kCollectorMapVCFraction)
        let collectorMapHiddenOriginy = CGRectGetMinY(containerBounds)
        collectorMapHiddenOrigin = CGPointMake(collectorMapHiddenOriginX, collectorMapHiddenOriginy)
        collectorMapVisibleOrigin = containerBounds.origin
    }
    
    func didRecieveOnSpotLocalNotification(notification :NSNotification) {
        
        let userInfo = notification.userInfo
        if let data = userInfo {
            
            let id = data[kPublicationUniqueIdKey] as? Int ?? 0
            let version = data[kPublicationVersionKey] as? Int ?? 0
            
            if id > 0 && version > 0 {
             
                let predicate = NSPredicate(format: "uniqueId = %@ && version = %@", NSNumber(integer: id) , NSNumber(integer: version))
                let results = (FCModel.sharedInstance.publications as NSArray).filteredArrayUsingPredicate(predicate) as! [Publication]
                if results.count > 0 {
                   
                    let publication = results.last!
                    let onSpotVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
                    onSpotVC.publication = publication
                    onSpotVC.delegate = self
                    
                    let navController = UINavigationController(rootViewController: onSpotVC) as UINavigationController
                    self.presentViewController(navController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func dismiss(report: PublicationReport?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
