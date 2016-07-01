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
    
    var isLoginStarted = false
    
    var identityProviderLogingViewNavVC: UINavigationController!
    var activityCenterVC: ActivityCenterVC!
    var collectorRootNavigationController: UINavigationController!
    var activityCenterPresented = false
    

    var collectorMapVisibleOrigin: CGPoint!
    var collectorMapHiddenOrigin: CGPoint!
    
    var statusBarHidden: Bool = false
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityCenterVC = self.storyboard?.instantiateViewControllerWithIdentifier("ActivityCenterVC") as! ActivityCenterVC
        
        self.addChildViewController(activityCenterVC)
        activityCenterVC.view.frame = self.view.bounds
        
        self.view.addSubview(self.activityCenterVC.view)
        self.activityCenterVC.didMoveToParentViewController(self)
        self.view.sendSubviewToBack(self.activityCenterVC.view)
        
      
//        for vc in self.childViewControllers {
//            if vc is CollectorMapVCNavController {
//                collectorRootNavigationController = vc as? UINavigationController
//                break
//            }
//        }

        for vc in self.childViewControllers {
            if vc is UINavigationController {
                collectorRootNavigationController = vc as? UINavigationController
                break
            }
        }

        
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCPublicationsTableViewController
        collectorRootVC.slideDelegate = self
        
        self.definePointsWithRect(self.view.bounds)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!User.sharedInstance.userIsLoggedIn && !User.sharedInstance.userSkippedLogin) {
            print("User is not Loged-in and didn't skip Login")
            showIdentityProviderLoginView()
        }
        else {
            print("User is Loged-in or skipped Login")
        }
        
        
        //let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        //storyBoard.instantiateInitialViewController() as! UINavigationController
        //self.presentViewController(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    }
    
    private func showIdentityProviderLoginView() {
        print("showIdentityProviderLoginView()")
        
        if !isLoginStarted {
            let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
            identityProviderLogingViewNavVC = loginStoryboard.instantiateViewControllerWithIdentifier("IdentityProviderLoginNavVC") as! UINavigationController
            
            self.presentViewController(self.identityProviderLogingViewNavVC, animated: true, completion: nil)
            isLoginStarted = true
        }
    }
    
    func collectorVCWillSlide() {
        if !activityCenterPresented { showActivityCenter() }
        else { hideActivityCenter() }
    }
    
    func showActivityCenter() {
        // Reload User Image and User Name string in activity center
        activityCenterPresented = true
        //let activityCenterVC = activityCenterVC.viewControllers[0] as! ActivityCenterVC
        //activityCenterVC.userIdentityProviderName.text = User.sharedInstance.userIdentityProviderUserName.capitalizedString
        //activityCenterVC.displayUserProfileImage()
        
        //inform collector root vc that activity center is presented
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCPublicationsTableViewController
        collectorRootVC.isPresentingActivityCenter = true
        self.mapNavigationControllerLeadingConstraint.constant = self.collectorMapHiddenOrigin.x - kConstraintsTotalPadding
        self.mapNavigationControllerTrailingConstraint.constant = -(self.collectorMapHiddenOrigin.x - kConstraintsTotalPadding)
        
        // Add shadow to the slided view
        let parentView = collectorRootVC.parentViewController!
        parentView.view.layer.shadowColor = UIColor.blackColor().CGColor
        parentView.view.layer.shadowOpacity = 0.6
        parentView.view.layer.shadowRadius = 5.0
        parentView.view.layer.shadowOffset = CGSizeMake(-5, 3)

        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
    
        }) { (completion) -> Void in}
    }
    
    func hideActivityCenter() {
        
        activityCenterPresented = false
        
        //inform collector root vc that activity center is presented
        let collectorRootVC = collectorRootNavigationController.viewControllers[0] as! FCPublicationsTableViewController
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
