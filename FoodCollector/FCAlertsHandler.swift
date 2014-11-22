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
        let dissmissAction = UIAlertAction(title:String.localizedStringWithFormat("Dissmiss", "alert dissmiss button title"), style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true , completion: nil)
        }
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

