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
    
    var isPresentingOnSpotReportVC = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.itemPositioning = UITabBarItemPositioning.Fill
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveOnspotNotification:", name: kDidArriveOnSpotNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentPrepareToDeleteMessage:", name: "prepareToDelete", object: nil)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().boolForKey(kDidReciveLocationNotificationInBackground){
            let userInfo = FCUserNotificationHandler.sharedInstance.recivedLocationNotification.last!
            let notification = NSNotification(name: "auto", object: self, userInfo: userInfo)
            self.didRecieveOnspotNotification(notification)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidReciveLocationNotificationInBackground)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 }
