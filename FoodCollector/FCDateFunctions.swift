//
//  FCDateFunctions.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
//  SingleTone


import Foundation

///
/// responsible of all Date formats to string and from strings.
///

class FCDateFunctions : NSObject {
    
    let dateFormatter = NSDateFormatter()
    
    func dateFromString (dateString: String) -> NSDate {
        
        let date = self.dateFormatter.dateFromString(dateString)
        
        return date!
    }
    
    class func localizedDateStringShortStyle(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
}


extension FCDateFunctions {
    
    
    //SingleTone Shared Instance
    class var sharedInstance : FCDateFunctions {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCDateFunctions? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCDateFunctions()
        }
        return Static.instance!
    }
}
