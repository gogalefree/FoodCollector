//
//  FCMainTabBarController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit


class FCMainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

          NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveOnspotNotification:", name: kDidArriveOnSpotNotification, object: nil)
    }
    
    func didRecieveOnspotNotification(notification: NSNotification) {

        let info = notification.userInfo
        if let userInfo = info {
            
            let publicationIdentifier = FCUserNotificationHandler.sharedInstance.identifierForInfo(userInfo)
            
            let publication = FCModel.sharedInstance.publicationWithIdentifier(publicationIdentifier)
            
            let arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as FCArrivedToPublicationSpotVC
            
            arrivedToSpotReportVC.publication = publication
            
            let navController = UINavigationController(rootViewController: arrivedToSpotReportVC) as UINavigationController
            let tab = self
            
            self.presentViewController(navController, animated: true, completion: nil)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self) 
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
