//
//  FCAlertsHandler.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
//  SingleTone


import Foundation
import UIKit

///
/// responsible of UIAlerts allocations


public class FCAlertsHandler : NSObject {
    
    public func alertWithDissmissButton(aTitle: String, aMessage: String) -> UIAlertController {
       
        let alertController = UIAlertController(title: aTitle, message:aMessage, preferredStyle: .Alert)
        let dissmissAction = UIAlertAction(title:kOKButtonTitle, style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
        alertController.addAction(dissmissAction)
        return alertController
    }
    
    
    public func alertWithCallDissmissButton(aTitle: String, aMessage: String, phoneNumber: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: aTitle, message:aMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let dissmissAction = UIAlertAction(title:kCancelButtonTitle, style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let callAction = UIAlertAction(title:NSLocalizedString("Call publisher", comment:"alert call to publisher button title"), style: UIAlertActionStyle.Default) { (action) in
            
            let url:NSURL = NSURL(string: "tel://\(phoneNumber)")!
            UIApplication.sharedApplication().openURL(url)

            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
        alertController.addAction(callAction)
        alertController.addAction(dissmissAction)
        return alertController
    }
    
    func navigationActionSheet(aTitle: String, publication: Publication) -> UIAlertController {
        
        let alertController = UIAlertController(title: aTitle, message:"", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let dissmissAction = UIAlertAction(title:kCancelButtonTitle, style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let wazeAction = UIAlertAction(title:NSLocalizedString("Waze", comment:"navigation button in action sheet meening waze navigation"), style: UIAlertActionStyle.Default) { (action) in
            FCNavigationHandler.sharedInstance.wazeNavigation(publication)
            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let mapsAction = UIAlertAction(title:NSLocalizedString("Apple Maps", comment:"navigation button in action sheet meening apple maps navigation"), style: UIAlertActionStyle.Default) { (action) in
            FCNavigationHandler.sharedInstance.appleMapsNavigation(publication)
            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
        
        alertController.addAction(wazeAction)
        alertController.addAction(mapsAction)
        alertController.addAction(dissmissAction)
        return alertController
    }


}






extension FCAlertsHandler {
    
    //SingleTone Shared Instance
    public class var sharedInstance : FCAlertsHandler {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCAlertsHandler? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCAlertsHandler()
        }
        return Static.instance!
    }

}

