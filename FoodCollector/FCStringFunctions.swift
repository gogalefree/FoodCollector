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
    
    class func longDistanceString (publication: Publication) -> String {
        //TODO: Use NSFormter for distance number formating and units nameing.
        let distanceNumbers = self.formmatedDistanceString(publication.distanceFromUserLocation)
        return  String.localizedStringWithFormat(NSLocalizedString("%@ km away", comment: "Distance from location of sharing. e.g: '55 km away'"),distanceNumbers)
        
    }
    
    class func shortDistanceString (publication: Publication) -> String {
        //TODO: Use NSFormter for distance number formating and units nameing.
        let distanceNumbers = self.formmatedDistanceString(publication.distanceFromUserLocation)
        return  String.localizedStringWithFormat(NSLocalizedString("(%@ km)", comment: "Distance from location of sharing. e.g: '55 km'"),distanceNumbers)
        
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

