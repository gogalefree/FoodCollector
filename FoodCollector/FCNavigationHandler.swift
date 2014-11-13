//
//  FCNavigationHandler.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
//  SingleTone


import Foundation

///
/// responsible for navigation logic with Waze or Apple Maps
///
class FCNavigationHandler : NSObject {
    
    
    
}



extension FCNavigationHandler {
    
    //SingleTone Shared Instance
    class var sharedInstance : FCNavigationHandler {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCNavigationHandler? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCNavigationHandler()
        }
        return Static.instance!
    }
}
