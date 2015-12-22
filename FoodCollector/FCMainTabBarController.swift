//
//  FCMainTabBarController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let kPublicationDeletedAlertMessage = NSLocalizedString("Event Ended Near You", comment:"A message that informs the user that a publication ended")

class FCMainTabBarController: UITabBarController, FCOnSpotPublicationReportDelegate , NewReportMessageViewDelegate{
    
    let kNewRegistrationBannerHiddenY: CGFloat = -80
    
    var isPresentingOnSpotReportVC = false
    var firstLaunch = true
    var mainActionNavVC: UINavigationController!
    var newRgistrationBannerView = NewRegistrationBannerView.loadFromNibNamed("NewRegistrationBannerView", bundle: nil) as! NewRegistrationBannerView    
    
    lazy var newReportMessageView: NewReportMessageView = NewReportMessageView.loadFromNibNamed("NewReportMessageView", bundle: nil) as! NewReportMessageView

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.itemPositioning = UITabBarItemPositioning.Fill
        registerNSNotifications()
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
        else {
         
            showNewReportIfNeeded()
        }
    }
    
    func showNewReportIfNeeded() {
       
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTypePublicationReport) as? [String : AnyObject]{
            
            let uniqueId = data[kPublicationUniqueIdKey] as! Int
            let version = data[kPublicationVersionKey] as! Int
            let identifier = PublicationIdentifier(uniqueId: uniqueId , version: version)
            let reportMessageRawValue = data[kRemoteNotificationPublicationReportMessageKey] as! Int
            let dateInt = data[kRemoteNotificationPublicationReportDateKey] as! Int
            let timeInterval = NSTimeInterval(dateInt)
            let reportMessage = FCOnSpotPublicationReportMessage(rawValue: reportMessageRawValue)!
            
            let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: reportMessage, date: NSDate(timeIntervalSince1970: timeInterval) , reportContactInfo: "", reportPublicationId: uniqueId, reportPublicationVersion: version ,reportId: 0 , reportCollectorName: "")
            
            FCUserNotificationHandler.sharedInstance.recivedReports.append((identifier , report))
            self.didRecievePublicationReport()
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
                
                let arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
                
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
            
            let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(publication.title!, aMessage: kPublicationDeletedAlertMessage)
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
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            self.newRgistrationBannerView.alpha = 1
            self.newRgistrationBannerView.frame = CGRectMake(0, 66 , CGRectGetWidth(self.view.bounds), 66)

        }) { (finished) -> Void in
            
            UIView.animateWithDuration(0.3, delay: 5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                
                self.newRgistrationBannerView.frame = CGRectMake(0, self.kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 66)
                self.newRgistrationBannerView.alpha = 0

                
            }){ (finished) -> Void in
             
                self.newRgistrationBannerView.removeFromSuperview()
                self.showNewReportIfNeeded()
            }
        }
    }
    
    //Triggered if a publicationReport arrived via remote notification 
    func didRecievePublicationReport() {
        
        //delete notification data
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRemoteNotificationTypePublicationReport)
        
        self.newReportMessageView.delegate = self

        let (identifier , report ) = FCUserNotificationHandler.sharedInstance.recivedReports.last!
        
        //for the user who created the publication - if the report is took all or nothing there, we suggest taking the publication off air
        //else we suggest to see the publication details tvc
        if let publication = FCModel.sharedInstance.userCreatedPublicationWithIdentifier(identifier) {
       
            self.newReportMessageView.userCreatedPublication = publication
            
            if report.onSpotPublicationReportMessage != FCOnSpotPublicationReportMessage.HasMore {
            
                self.newReportMessageView.state = .NothingLeft
            }
                
            else {
            //present message with show details button
                self.newReportMessageView.state = .HasMore
            }
            
            self.presentNewReportMessageView()
        }
        //for a registered user who did not create the publication
        else if let publication = FCModel.sharedInstance.publicationWithIdentifier(identifier) {
            
            self.newReportMessageView.userCreatedPublication = publication
            self.newReportMessageView.state = .RegisteredUser
            self.presentNewReportMessageView()
        }
    }
    
    func presentNewReportMessageView() {
        
        self.newReportMessageView.frame = CGRectMake(0, self.kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 129)
        self.view.addSubview(self.newReportMessageView)
        self.view.bringSubviewToFront(self.newReportMessageView)
        

        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
    
            self.newReportMessageView.alpha = 1
            self.newReportMessageView.frame = CGRectMake(0, 66 , CGRectGetWidth(self.view.bounds), 129)

        }, completion: nil)
    }
    
    func hideNewReportMessageView() {
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            self.newReportMessageView.frame = CGRectMake(0, self.kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 129)
            self.newReportMessageView.alpha = 0
            }){ (finished) -> Void in
                self.newReportMessageView.removeFromSuperview()
                self.newReportMessageView.reset()
        }
    }
    
    func newReportMessageViewActionDissmiss() {
        self.hideNewReportMessageView()
    }
    
    func newReportMessageViewActionTakeOffAir(publication: FCPublication) {
        
            //update model
            publication.isOnAir = false
            FCModel.sharedInstance.saveUserCreatedPublications()
        
            //inform server and model
            FCModel.sharedInstance.foodCollectorWebServer.takePublicationOffAir(publication, completion: { (success) -> Void in
                
                if success{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.hideNewReportMessageView()
                        let publicationIdentifier = PublicationIdentifier(uniqueId: publication.uniqueId, version: publication.version)
                        FCUserNotificationHandler.sharedInstance.recivedtoDelete.append(publicationIdentifier)
                        FCModel.sharedInstance.deletePublication(publicationIdentifier, deleteFromServer: false, deleteUserCreatedPublication: false)
                    })
                }
                else{
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(kCommunicationIssueTitle, aMessage: kCommunicationIssueBody)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
    }
    
    func newReportMessageViewActionShowDetails(publication: FCPublication) {
        
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        publicationDetailsTVC?.title = publication.title
        publicationDetailsTVC?.publication = publication
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
        let navController = UINavigationController(rootViewController: publicationDetailsTVC!)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func dismissDetailVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func registerNSNotifications() {
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveOnspotNotification:", name: kDidArriveOnSpotNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentPrepareToDeleteMessage:", name: "prepareToDelete", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationReport", name: kRecivedPublicationReportNotification, object: nil)
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
