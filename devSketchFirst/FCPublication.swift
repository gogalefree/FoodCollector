//
//  FCPublication.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import Foundation
import CoreLocation
import MapKit

///
/// Base Entity.
/// represents an event in which food is being shared.
///

class FCPublication : NSObject, MKAnnotation { //NSSecureCoding,
    
    var photoUrl:String?
    var address:String
    var title:String
    var distanceFromUserLocation:Double?
    var typeOfCollecting:FCTypeOfCollecting
    var coordinate:CLLocationCoordinate2D
    var endingDate:NSDate
    var uniqueId:UInt
    var startingDate:NSDate
    var contactInfo:String?
    var subtitle:String?
    
    init(coordinates:CLLocationCoordinate2D, title:String, endingDate:NSDate, typeOfCollecting:FCTypeOfCollecting, startingDate:NSDate, uniqueId:UInt, address:String) {
        
        self.coordinate = coordinates
        self.title = title
        self.endingDate = endingDate
        self.typeOfCollecting = typeOfCollecting
        self.startingDate = startingDate
        self.uniqueId = uniqueId
        self.address = address
        
        super.init()
        
    }
    // MARK: - NSSecureCoding protocol
    
    class func supportsSecureCoding() -> Bool {
        return true
    }
    
    func encodeWithCoder(aCoder: NSCoder){
        
    }
   /*
    required init(coder aDecoder: NSCoder) {
        
        
    }
    */
    
    ///
    /// creates a Publication instance from Params dictionary
    ///
    class func publicationWithParams(params: [String:AnyObject]) {
        
    }
    
}

