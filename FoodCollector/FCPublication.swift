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

let kPublicationUniqueIdKey = "publication_unique_id"
let kPublicationVersionKey = "publication_version"
let kPublicationTitleKey = "publication_title"
let kPublicationSubTitleKey = "publication_subtitle"
let kPublicationAddressKey = "publication_address"
let kPublicationTypeOfCollectingKey = "publication_type_of_collecting"
let kPublicationlatitudeKey = "publication_latitude"
let kPublicationLongtitudeKey = "publication_longtitude"
let kPublicationStartingDtae = "publication_starting_date"
let kPublicationEndingDateKey = "publication_ending_date"
let kPublicationContactInfoKey = "publication_contact_info"
let kPublicationPhotoUrl = "publication_photo_url"

///
/// Base Entity.
/// represents an event in which food is being shared.
///

public class FCPublication : NSObject, MKAnnotation { //NSSecureCoding,
    
    public var uniqueId: Int
    public var version: Int
    public var title:String
    public var subtitle:String?
    public var address:String
    public var typeOfCollecting:FCTypeOfCollecting
    public var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    public var startingDate:NSDate
    public var endingDate:NSDate
    public var contactInfo:String?
    public var photoUrl:String?
    public var distanceFromUserLocation:Double {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return location.distanceFromLocation(FCModel.sharedInstance.userLocation)
    }

    
    public init(coordinates: CLLocationCoordinate2D,
        theTitle: String, endingDate: NSDate,
        typeOfCollecting: FCTypeOfCollecting, startingDate: NSDate,
        uniqueId: Int, address: String, photoUrl: String?,
        contactInfo: String?, subTitle: String?, version: Int) {
        
            self.uniqueId = uniqueId
            self.version = version
            self.title = theTitle
            self.subtitle = subTitle
            self.address = address
            self.typeOfCollecting = typeOfCollecting
            self.coordinate = coordinates
            self.startingDate = startingDate
            self.endingDate = endingDate
            self.contactInfo = contactInfo
            self.photoUrl = photoUrl
            super.init()
    }
    
    
    // MARK: - NSSecureCoding protocol
    
    
    public func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeInteger(self.uniqueId, forKey: kPublicationUniqueIdKey)
        aCoder.encodeInteger(self.version, forKey: kPublicationVersionKey)
        aCoder.encodeObject(self.title, forKey: kPublicationTitleKey)
        aCoder.encodeObject(self.subtitle, forKey: kPublicationSubTitleKey)
        aCoder.encodeObject(self.address, forKey: kPublicationAddressKey)
        aCoder.encodeInteger(self.typeOfCollecting.rawValue, forKey: kPublicationTypeOfCollectingKey)
        aCoder.encodeDouble(self.coordinate.latitude, forKey: kPublicationlatitudeKey)
        aCoder.encodeDouble(self.coordinate.longitude, forKey: kPublicationLongtitudeKey)
        aCoder.encodeObject(self.startingDate, forKey: kPublicationStartingDtae)
        aCoder.encodeObject(self.endingDate, forKey: kPublicationEndingDateKey)
        aCoder.encodeObject(self.contactInfo, forKey: kPublicationContactInfoKey)
        aCoder.encodeObject(self.photoUrl, forKey: kPublicationPhotoUrl)
    }
   
    public required init(coder aDecoder: NSCoder) {
        
        self.uniqueId = aDecoder.decodeIntegerForKey(kPublicationUniqueIdKey)
        self.version = aDecoder.decodeIntegerForKey(kPublicationVersionKey)
        self.title = aDecoder.decodeObjectForKey(kPublicationTitleKey) as String
        self.subtitle = aDecoder.decodeObjectForKey(kPublicationSubTitleKey) as? String
        self.address = aDecoder.decodeObjectForKey(kPublicationAddressKey) as String
        self.typeOfCollecting = FCTypeOfCollecting(rawValue: aDecoder.decodeIntegerForKey(kPublicationTypeOfCollectingKey))!
        
        let latitude = aDecoder.decodeDoubleForKey(kPublicationlatitudeKey)
        let longtitude = aDecoder.decodeDoubleForKey(kPublicationLongtitudeKey)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        
        self.startingDate = aDecoder.decodeObjectForKey(kPublicationStartingDtae) as NSDate
        self.endingDate = aDecoder.decodeObjectForKey(kPublicationEndingDateKey) as NSDate
        self.contactInfo = aDecoder.decodeObjectForKey(kPublicationContactInfoKey) as? String
        self.photoUrl = aDecoder.decodeObjectForKey(kPublicationPhotoUrl) as? String
        
        super.init()
    }
    
    class func supportsSecureCoding() -> Bool {
        return true
    }
    
    
    
    ///
    /// creates a Publication instance from Params dictionary
    ///
    public class func publicationWithParams(params: [String:AnyObject]) -> FCPublication {
        
        let dict = params as NSDictionary
        let aUniquId = (dict.objectForKey(kPublicationUniqueIdKey) as NSNumber).integerValue
        var aTitle = dict.objectForKey(kPublicationTitleKey) as NSString
        let aSubTitle  = dict.objectForKey(kPublicationSubTitleKey) as String
        let anAddress = dict.objectForKey(kPublicationAddressKey) as String
        let aTypeOfCollecting = FCTypeOfCollecting(rawValue: (dict.objectForKey(kPublicationTypeOfCollectingKey) as NSNumber).integerValue)
        let aLatitude = (dict.objectForKey(kPublicationLongtitudeKey) as NSNumber).doubleValue
        let aLongtitude = (dict.objectForKey(kPublicationLongtitudeKey) as NSNumber).doubleValue
        let aCoordinateds = CLLocationCoordinate2D(latitude: aLatitude, longitude: aLongtitude)
        let aStartingDate = dict.objectForKey(kPublicationStartingDtae) as NSDate
        let aEndingDate = dict.objectForKey(kPublicationEndingDateKey) as NSDate
        let aContactInfo = dict.objectForKey(kPublicationContactInfoKey) as String
        let aPhotoUrl = dict.objectForKey(kPublicationPhotoUrl) as String
        let aVersion = (dict.objectForKey(kPublicationVersionKey) as NSNumber).integerValue
        
        let publication = FCPublication(coordinates: aCoordinateds, theTitle: aTitle, endingDate: aEndingDate, typeOfCollecting: aTypeOfCollecting!, startingDate: aStartingDate, uniqueId: aUniquId, address: anAddress, photoUrl: aPhotoUrl, contactInfo: aContactInfo, subTitle: aSubTitle, version: aVersion)
        return publication
    }
    
}

