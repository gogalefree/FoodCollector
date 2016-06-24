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
        if timeInterval > 0 {
            let totalHours = timeInterval / 60 / 60
            let totalDays = totalHours / 24
            let remainingHours = totalHours % 24
            
            if totalDays == 0 { // less than a day to end date
                let remainingMinutes = Int(totalHours % 60)
                return "\(remainingHours)h \(remainingMinutes)m" // "2h 12m"
            }
            
            if totalHours == 0 { // less than an hour to end date
                let remainingMinutes = Int(timeInterval / 60)
                let timeString = String.localizedStringWithFormat(NSLocalizedString("%@ minutes", comment: "Time remaining. e.g: '35 minutes'"), "\(remainingMinutes)")
                return timeString // "35 minutes"
            }
            
            return "\(totalDays)d \(remainingHours)h" // "2d 1h"
        }
        else {
            return "0d 0h"
        }
    }
    
    class func timeStringDaysAndHoursRemainVerbose(fromDate fromDate: NSDate, toDate: NSDate) -> String {
        let timeInterval = Int(fromDate.timeIntervalSinceDate(toDate)) // NSTimeInterval is Double
        if timeInterval > 0 {
            let totalHours = timeInterval / 60 / 60
            if totalHours == 0 { // less than an hour to end date
                let remainingMinutes = Int(timeInterval / 60)
                return String.localizedStringWithFormat(NSLocalizedString("Ends: %@ min", comment: "Time remaining. e.g: 'Ends: 35 min'"), "\(remainingMinutes)")
            }
            
            let remainingDays = Int(totalHours / 24)
            let remainingHours = totalHours % 24
            return String.localizedStringWithFormat(NSLocalizedString("Ends: %@d and %@h", comment: "Time remaining in days and hours. e.g: 'Ends: 2 and 3h'"), "\(remainingDays)", "\(remainingHours)")
        }
        else {
            return NSLocalizedString("Ended", comment: "No time remains. Publication ended.")
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
    
    class func timeStringForActivityLogCell(objectDate: NSDate) -> String{
        
        var timeString = ""
        
        let logTimeInterval = -objectDate.timeIntervalSinceNow
        let hours = Int(logTimeInterval / 60 / 60)
        
        if hours == 0 {
            //show minutes
            let minutes = Int(logTimeInterval / 60)
            let minString = NSLocalizedString("mins", comment: "a shorted version of minutes")
            timeString = "\(minutes) " + minString
        }
        
        else if hours > 24 {
            //show days
            let days = Int(hours / 24)
            let daysString = NSLocalizedString("days", comment: "days passed from date")
            timeString = "\(days) " + daysString
        }
        
        else {
            //show hours
            let hoursString = NSLocalizedString("h", comment: "hours passed from date")
            timeString = "\(hours) " + hoursString
        }
        
        return timeString
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
