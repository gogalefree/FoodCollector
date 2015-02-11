//
//  FCMainTabBarController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit


class FCMainTabBarController: UITabBarController, FCOnSpotPublicationReportDelegate {
    
    var isPresentingOnSpotReportVC = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveOnspotNotification:", name: kDidArriveOnSpotNotification, object: nil)
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
                
                var arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as FCArrivedToPublicationSpotVC
                
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 }
