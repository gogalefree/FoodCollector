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

let kPublicationUniqueIdKey = "unique_id"
let kPublicationVersionKey = "version"
let kPublicationTitleKey = "title"
let kPublicationSubTitleKey = "subtitle"
let kPublicationAddressKey = "address"
let kPublicationTypeOfCollectingKey = "type_of_collecting"
let kPublicationlatitudeKey = "latitude"
let kPublicationLongtitudeKey = "longitude"
let kPublicationStartingDateKey = "starting_date"
let kPublicationEndingDateKey = "ending_date"
let kPublicationContactInfoKey = "contact_info"
let kPublicationPhotoUrl = "photo_url"


struct PublicationIdentifier {
    
    let uniqueId: Int
    let version: Int
}

struct FCRegistrationForPublication {
    
    enum RegistrationMessage: Int {
        case register = 1
        case unRegister = 2
    }
    
    var identifier: PublicationIdentifier
    var dateOfOrder: NSDate
    var registrationMessage: RegistrationMessage
}



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
    var reportsForPublication = [FCOnSpotPublicationReport]()
    var registrationsForPublication = [FCRegistrationForPublication]()
    
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
    
    deinit {
        println("DEINIT publication id: \(self.uniqueId) version: \(self.version)")
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
        aCoder.encodeObject(self.startingDate, forKey: kPublicationStartingDateKey)
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
        
        self.startingDate = aDecoder.decodeObjectForKey(kPublicationEndingDateKey) as NSDate
        self.endingDate = aDecoder.decodeObjectForKey(kPublicationEndingDateKey) as NSDate
        self.contactInfo = aDecoder.decodeObjectForKey(kPublicationContactInfoKey) as? String
        self.photoUrl = aDecoder.decodeObjectForKey(kPublicationPhotoUrl) as? String
        
        super.init()
    }
    
    class func supportsSecureCoding() -> Bool {
        return true
    }
    
    
    
    public class func publicationWithParams(params: [NSObject: AnyObject]) -> FCPublication {
        
        let aUniquId = params[kPublicationUniqueIdKey]! as Int
        let aTitle = params[kPublicationTitleKey]! as String
        let aSubTitle  = params[kPublicationSubTitleKey] as? String ?? ""
        let anAddress = params[kPublicationAddressKey] as? String ?? ""
        let aTypeOfCollecting = FCTypeOfCollecting(rawValue: params[kPublicationTypeOfCollectingKey]! as Int)
        let aLatitude = params[kPublicationLongtitudeKey]! as Double
        let aLongtitude = params[kPublicationLongtitudeKey]! as Double
        let aCoordinateds = CLLocationCoordinate2D(latitude: aLatitude, longitude: aLongtitude)
        let aStartingDate = NSDate(timeIntervalSince1970: NSTimeInterval(params[kPublicationStartingDateKey]! as Int))
        let aEndingDate = NSDate(timeIntervalSince1970: NSTimeInterval(params[kPublicationEndingDateKey]! as Int))
        let aContactInfo = params[kPublicationContactInfoKey] as? String ?? ""
        let aPhotoUrl = params[kPublicationPhotoUrl] as? String ?? ""
        let aVersion = params[kPublicationVersionKey]! as Int
        let publication = FCPublication(coordinates: aCoordinateds, theTitle: aTitle, endingDate: aEndingDate, typeOfCollecting: aTypeOfCollecting!, startingDate: aStartingDate, uniqueId: aUniquId, address: anAddress, photoUrl: aPhotoUrl, contactInfo: aContactInfo, subTitle: aSubTitle, version: aVersion)
        return publication
    }
    
}

