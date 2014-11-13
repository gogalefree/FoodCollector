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


class FCAlertsHandler : NSObject {
    
}






extension FCAlertsHandler {
    
    //SingleTone Shared Instance
    class var sharedInstance : FCAlertsHandler {
        
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

