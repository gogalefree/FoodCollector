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
    // TODO: Add support for Miles distance unit (not just Kilometers)
    class func formmatedDistanceString (distance: Double) -> String{
        
        let km = distance / 1000
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = 2
        let distanceString = numberFormatter.stringFromNumber(NSNumber(double: km))
        return distanceString!
    }
    
    class func longDistanceString (publication: FCPublication) -> String {
        //TODO: Use NSFormter for distance number formating and units nameing.
        let distanceText = NSLocalizedString("Km", comment:"describes the number of km from the user's location")
        let distanceNumbers = self.formmatedDistanceString(publication.distanceFromUserLocation)
        return  String.localizedStringWithFormat(NSLocalizedString("%@ %@ away", comment: "Distance from location of sharing. the first place holder is a number, the second placeholder is the distance unit, e.g: '55 km away'"),distanceNumbers , distanceText)
        
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

