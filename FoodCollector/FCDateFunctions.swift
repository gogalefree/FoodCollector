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
    
    class func PublicationDidExpired(endingDate: NSDate) -> Bool {
        // If timeIntervalSinceDate is bigger than 0, it means that the
        // event is active and the result of PublicationDidExpired needs
        // to be false.
        if endingDate.timeIntervalSinceNow > 0 {
            return false
        }
        else {

            return true
        }
    }
    
    class func localizedDateStringShortStyle(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    class func localizedTimeStringShortStyle(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    class func localizedDateAndTimeStringShortStyle(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
    }
    
    class func timeStringEuroStyle(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = NSLocale.currentLocale()
        return formatter.stringFromDate(date)
    }
    
    class func timeStringDaysAndHoursRemain(fromDate fromDate: NSDate, toDate: NSDate) -> String {
        let timeInterval = Int(fromDate.timeIntervalSinceDate(toDate)) // NSTimeInterval is Double
        print("tiemInterval: \(timeInterval)")
        if timeInterval > 0 {
            print("timeInterval > 0")
            let totalHours = timeInterval / 60 / 60
            if totalHours == 0 { // less than an hour to end date
                print("totalHours == 0")
                let remainingMinutes = Int(timeInterval / 60)
                return "0H \(remainingMinutes)M" // "0H 1M"
            }
            
            let remainingDays = Int(totalHours / 24)
            let remainingHours = totalHours % 24
            return "\(remainingDays)D \(remainingHours)H" // "2D 1H"
        }
        else {
            return "0D 0H"
        }
    }
    
    class func timeStringDaysAndHoursRemainWithColor(fromDate fromDate: NSDate, toDate: NSDate) -> (String, UIColor) {
        
        let timeInterval = Int(fromDate.timeIntervalSinceDate(toDate)) // NSTimeInterval is Double
        if timeInterval > 0 {
            let timeString = timeStringDaysAndHoursRemain(fromDate: fromDate, toDate: toDate)
            let textColor = UIColor(red: 65/255, green: 117/255, blue: 5/255, alpha: 1)
            return (timeString, textColor)
        }
        else {
            let timeString = NSLocalizedString("Ended", comment: "The time for publication has ended.")
            let textColor = UIColor(red: 255/255, green: 39/255, blue: 39/255, alpha: 1)
            return (timeString, textColor)
        }
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
