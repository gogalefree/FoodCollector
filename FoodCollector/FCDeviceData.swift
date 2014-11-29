//
//  FCDeviceData.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 24/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

/// responsible of getting device data


class FCDeviceData: NSObject {
    
    class func screenWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    
    class func screenHight() -> CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
   
}



extension FCDeviceData {
    
    //SingleTone Shared Instance
    class var sharedInstance : FCDeviceData {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCDeviceData? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCDeviceData()
        }
        return Static.instance!
    }
    
}