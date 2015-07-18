//
//  FCMainTabBarController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let kpublicationDeletedAlertMessage = String.localizedStringWithFormat("אירוע הסתיים בקירבתך:", "a message that informs the user that nothing was left and the publication ended")

class FCMainTabBarController: UITabBarController, FCOnSpotPublicationReportDelegate {
    
    let kNewRegistrationBannerHiddenY: CGFloat = -80
    
    var isPresentingOnSpotReportVC = false
    var firstLaunch = true
    var mainActionNavVC: UINavigationController!
    var newRgistrationBannerView = NewRegistrationBannerView.loadFromNibNamed("NewRegistrationBannerView", bundle: nil) as! NewRegistrationBannerView
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.itemPositioning = UITabBarItemPositioning.Fill
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveOnspotNotification:", name: kDidArriveOnSpotNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentPrepareToDeleteMessage:", name: "prepareToDelete", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)

        
        self.mainActionNavVC = self.storyboard?.instantiateViewControllerWithIdentifier("MainActionNavVC") as! UINavigationController

        let mainActionVC = self.mainActionNavVC.viewControllers[0] as! MainActionVC
        mainActionVC.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if firstLaunch {
            //self.presentViewController(self.mainActionNavVC, animated: false, completion: nil)
            self.addChildViewController(self.mainActionNavVC)
            self.mainActionNavVC.view.frame = self.view.bounds
            self.view.addSubview(self.mainActionNavVC.view)
            self.mainActionNavVC.didMoveToParentViewController(self)
            firstLaunch = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        //Location Notification
        if NSUserDefaults.standardUserDefaults().boolForKey(kDidReciveLocationNotificationInBackground){
            let userInfo = FCUserNotificationHandler.sharedInstance.recivedLocationNotification.last!
            let notification = NSNotification(name: "auto", object: self, userInfo: userInfo)
            self.didRecieveOnspotNotification(notification)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidReciveLocationNotificationInBackground)
        }
        
        //RegistrationForPublication Remote Notification while the app was inActive
        self.showUserRegistrationNotificationIfNeeded(1.5)
        
    }
    
    func appWillEnterForeground() {
        self.showUserRegistrationNotificationIfNeeded(1.5)
    }
    
    final func showUserRegistrationNotificationIfNeeded(dealey: NSTimeInterval) {
        
         if let data = NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTypeUserRegisteredForPublication) as? [String : AnyObject]{
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(dealey * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in

                
                        let id = data[kPublicationUniqueIdKey] as! Int
                        let version = data[kPublicationVersionKey] as! Int
                        let identifier = PublicationIdentifier(uniqueId: id, version: version)
                        let publication = FCModel.sharedInstance.userCreatedPublicationWithIdentifier(identifier)
                        if let publication = publication {
                            self.newRgistrationBannerView.reset()
                            self.newRgistrationBannerView.userCreatedPublication = publication
                            self.presentNewRegistrationBanner()
                        }
                        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRemoteNotificationTypeUserRegisteredForPublication)
                
            })
        }
    }
    
    func didRecieveOnspotNotification(notification: NSNotification) {
        
        if isPresentingOnSpotReportVC{
            dismiss()
            didRecieveOnspotNotification(notification)
        }
        else {
            
            let info = notification.userInfo
            if let userInfo = info {
                
                let publicationIdentifier = FCUserNotificationHandler.sharedInstance.identifierForInfo(userInfo)
                
                let publication = FCModel.sharedInstance.publicationWithIdentifier(publicationIdentifier)
                
                var arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
                
                arrivedToSpotReportVC.publication = publication
                arrivedToSpotReportVC.delegate = self
            
                let navController = UINavigationController(rootViewController: arrivedToSpotReportVC) as UINavigationController
                
                self.presentViewController(navController, animated: true, completion: nil)
                isPresentingOnSpotReportVC = true
            }
        }
    }
    
    func dismiss() {
        if self.presentedViewController != nil {
        self.dismissViewControllerAnimated(true, completion: nil)
        isPresentingOnSpotReportVC = false
        }
    }
    
    //this event fires if the user is registered
    //just before it expires
    func presentPrepareToDeleteMessage(notification: NSNotification) {
        
        let info = notification.userInfo as? [String : AnyObject]

        if let userInfo = info {
        
            let publication = userInfo["publication"] as! FCPublication
            
            let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(publication.title, aMessage: kpublicationDeletedAlertMessage)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //triggered when a new publicationRegistration push notification has arrived
    //that means that a user is registered to come pick up a user created publication
    func didRecievePublicationRegistration(notification: NSNotification) {
        
        let info = notification.userInfo as? [String : AnyObject]
        
        if let userInfo = info {
            
            let publication = userInfo["publication"] as! FCPublication
            self.newRgistrationBannerView.reset()
            self.newRgistrationBannerView.userCreatedPublication = publication
            self.presentNewRegistrationBanner()
        }
    }
    
    func presentNewRegistrationBanner() {
        self.newRgistrationBannerView.frame = CGRectMake(0, self.kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 66)
        self.view.addSubview(self.newRgistrationBannerView)
        self.view.bringSubviewToFront(self.newRgistrationBannerView)
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            
            self.newRgistrationBannerView.alpha = 1
            self.newRgistrationBannerView.frame = CGRectMake(0, 66 , CGRectGetWidth(self.view.bounds), 66)

        }) { (finished) -> Void in
            
            UIView.animateWithDuration(0.3, delay: 5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                
                self.newRgistrationBannerView.frame = CGRectMake(0, self.kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 66)
                self.newRgistrationBannerView.alpha = 0

                
            }){ (finished) -> Void in
             
                self.newRgistrationBannerView.removeFromSuperview()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 }

extension FCMainTabBarController: MainActionVCDelegate {
    
    func mainActionVCDidRequestAction(actionType: MainActionType) {
     
        self.selectedIndex = actionType.rawValue
    }
}
