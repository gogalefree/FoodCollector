//
//  FCStringFunctions.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
//  SingleTone


import Foundation

///
/// responsible for all string validations and processing
///
class FCStringFunctions : NSObject {
    
    class func formmatedDistanceString (distance: Double) -> String{
        
        var km = distance / 1000
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = 2
        let distanceString = numberFormatter.stringFromNumber(NSNumber(double: km))
        return distanceString!
    }
    
}



extension FCStringFunctions {
    
    
    //SingleTone Shared Instance
    class var sharedInstance : FCStringFunctions {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCStringFunctions? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCStringFunctions()
        }
        return Static.instance!
    }
}

