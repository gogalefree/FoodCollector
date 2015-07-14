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

let kPublicationUniqueIdKey = "id"
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
let kPublicationIsOnAirKey = "is_on_air"
let kDidRegisterForCurrentPublicationKey = "did_Register_for_current_publication"
let kDidModifyCoordinatesKey = "did_modify_coords"
let kReportsMessageArray = "reportsMessageArray"
let kReportsDateArray = "reportsDateArray"
let kPublicationCountOfRegisteredUsersKey = "pulbicationCountOfRegisteredUsersKey"

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

struct PhotoData {
    var photo: UIImage? = nil
    var didTryToDonwloadImage = false
}

public class FCPublication : NSObject, MKAnnotation { //NSSecureCoding,
    
    public var uniqueId: Int
    public var version: Int
    public var title:String
    public var subtitle:String?
    public var address:String
    public var typeOfCollecting: FCTypeOfCollecting
    public var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    public var startingDate:NSDate
    public var endingDate:NSDate
    public var contactInfo:String?
    public var isOnAir: Bool
    public var didModifyCoords : Bool
    public var photoUrl:String
    var photoData = PhotoData()
    public var  distanceFromUserLocation:Double {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distanceFromLocation(FCModel.sharedInstance.userLocation)
    }
    var reportsForPublication = [FCOnSpotPublicationReport]()
    
    // True if the current user registered for this publication
    var didRegisterForCurrentPublication:Bool = false {
        didSet{
            if didRegisterForCurrentPublication {
                FCUserNotificationHandler.sharedInstance.removeLocationNotification(self)
                FCUserNotificationHandler.sharedInstance.registerLocalNotification(self)
            }
            else if !didRegisterForCurrentPublication{
                FCUserNotificationHandler.sharedInstance.removeLocationNotification(self)
            }
        }
    }
    
    //publication's registrations array holds only instances with a register message.
    //when an unrigister push notification arrives the unregistered publication is taken out
    
    var registrationsForPublication = [FCRegistrationForPublication]()
    
    //the count of registered devices. is set in initial data download.
    var countOfRegisteredUsers = 0
    
    
    
    
    
    public init(coordinates: CLLocationCoordinate2D,
        theTitle: String, endingDate: NSDate,
        typeOfCollecting: FCTypeOfCollecting, startingDate: NSDate,
        uniqueId: Int, address: String,
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
            self.isOnAir = true
            self.photoUrl = "\(uniqueId).\(version).jpg"
            self.didRegisterForCurrentPublication = false
            self.didModifyCoords = false
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
        aCoder.encodeObject(self.startingDate, forKey: kPublicationStartingDateKey)
        aCoder.encodeObject(self.endingDate, forKey: kPublicationEndingDateKey)
        aCoder.encodeObject(self.contactInfo, forKey: kPublicationContactInfoKey)
        aCoder.encodeObject(self.photoUrl, forKey: kPublicationPhotoUrl)
        aCoder.encodeBool(self.isOnAir, forKey: kPublicationIsOnAirKey)
        aCoder.encodeBool(self.didRegisterForCurrentPublication, forKey: kDidRegisterForCurrentPublicationKey)
        aCoder.encodeBool(self.didModifyCoords, forKey: kDidModifyCoordinatesKey)
        aCoder.encodeInteger(self.countOfRegisteredUsers, forKey: kPublicationCountOfRegisteredUsersKey)
        

    
        var reportsMessageArray = [Int]()
        var reportsDateArray = [Int]()
        
        for onSporReport in self.reportsForPublication {
            reportsMessageArray.append(onSporReport.onSpotPublicationReportMessage.rawValue)
            reportsDateArray.append(Int(onSporReport.date.timeIntervalSince1970))
        }
        
        aCoder.encodeObject(reportsMessageArray, forKey: kReportsMessageArray)
        aCoder.encodeObject(reportsDateArray, forKey: kReportsDateArray )
    }
    
    public required init(coder aDecoder: NSCoder) {

        self.uniqueId = aDecoder.decodeIntegerForKey(kPublicationUniqueIdKey)
        self.version = aDecoder.decodeIntegerForKey(kPublicationVersionKey)
        self.title = aDecoder.decodeObjectForKey(kPublicationTitleKey) as! String
        self.subtitle = aDecoder.decodeObjectForKey(kPublicationSubTitleKey) as? String
        self.address = aDecoder.decodeObjectForKey(kPublicationAddressKey) as! String
        self.typeOfCollecting = FCTypeOfCollecting(rawValue: aDecoder.decodeIntegerForKey(kPublicationTypeOfCollectingKey))!
        
        let latitude = aDecoder.decodeDoubleForKey(kPublicationlatitudeKey)
        let longtitude = aDecoder.decodeDoubleForKey(kPublicationLongtitudeKey)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        
        self.startingDate = aDecoder.decodeObjectForKey(kPublicationStartingDateKey) as! NSDate
        self.endingDate = aDecoder.decodeObjectForKey(kPublicationEndingDateKey) as! NSDate
        self.contactInfo = aDecoder.decodeObjectForKey(kPublicationContactInfoKey) as? String
        self.photoUrl = aDecoder.decodeObjectForKey(kPublicationPhotoUrl) as! String
        self.isOnAir = aDecoder.decodeBoolForKey(kPublicationIsOnAirKey) as Bool
        self.didRegisterForCurrentPublication = aDecoder.decodeBoolForKey(kDidRegisterForCurrentPublicationKey) as Bool
        self.didModifyCoords = aDecoder.decodeBoolForKey(kDidModifyCoordinatesKey) as Bool
        self.countOfRegisteredUsers = aDecoder.decodeIntegerForKey(kPublicationCountOfRegisteredUsersKey) as Int
      
        
        var reportsMessageArray : [Int]? = [Int]()
        var reportsDateArray : [Int]? = [Int]()

        var publicationReports = [FCOnSpotPublicationReport]()
        
        reportsMessageArray = aDecoder.decodeObjectForKey(kReportsMessageArray) as? [Int]
        reportsDateArray = aDecoder.decodeObjectForKey(kReportsDateArray) as? [Int]

        if let reportsMessageArray = reportsMessageArray {
        if let reportsDateArray = reportsDateArray {
       
            let count = min(reportsMessageArray.count, reportsDateArray.count)
            
            for index in 0..<count {
                
                let message = reportsMessageArray[index]
                let date = NSDate(timeIntervalSince1970: NSTimeInterval (reportsDateArray[index]))
                
                let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage(rawValue: message)!, date: date)
                
                publicationReports.append(report)
            }
            
            self.reportsForPublication = publicationReports
        }
        }
        
        super.init()
    }
    
    class func supportsSecureCoding() -> Bool {
        return true
    }
    
    
    
    public class func publicationWithParams(params: [String: AnyObject]) -> FCPublication {
        
        let aUniquId = params[kPublicationUniqueIdKey] as! Int
        let aTitle = params[kPublicationTitleKey] as! String
        let aSubTitle  = params[kPublicationSubTitleKey] as? String ?? ""
        let anAddress = params[kPublicationAddressKey] as? String ?? ""
        let aTypeOfCollecting = FCTypeOfCollecting(rawValue: params[kPublicationTypeOfCollectingKey] as! Int)
        let aLatitude =  (params[kPublicationlatitudeKey] as! NSString).doubleValue
        let aLongtitude = (params[kPublicationLongtitudeKey] as! NSString).doubleValue
        let aCoordinateds = CLLocationCoordinate2D(latitude: aLatitude, longitude: aLongtitude)
        let startingDateDouble = (params[kPublicationStartingDateKey] as! NSString).doubleValue
        let startingDateInt = Int(startingDateDouble)
        let aStartingDate = NSDate(timeIntervalSince1970: NSTimeInterval(startingDateInt))
        
        let endingDateDouble = (params[kPublicationEndingDateKey] as! NSString).doubleValue
        let endingDateInt = Int(endingDateDouble)
        let aEndingDate = NSDate(timeIntervalSince1970: NSTimeInterval(endingDateDouble))
        let aContactInfo = params[kPublicationContactInfoKey] as? String ?? ""
        let aVersion = params[kPublicationVersionKey] as! Int
        let aPhotoUrl = "\(aUniquId).\(aVersion).jpg"
        let publication = FCPublication(coordinates: aCoordinateds, theTitle: aTitle, endingDate: aEndingDate, typeOfCollecting: aTypeOfCollecting!, startingDate: aStartingDate, uniqueId: aUniquId, address: anAddress,  contactInfo: aContactInfo, subTitle: aSubTitle, version: aVersion)
        return publication
    }
    
    class func userCreatedPublicationWithParams(params: [String : AnyObject]) -> FCPublication {
       
        let aUniquId = params[kPublicationUniqueIdKey] as! Int
        let aTitle = params[kPublicationTitleKey] as! String
        let aSubTitle  = params[kPublicationSubTitleKey] as? String ?? ""
        let anAddress = params[kPublicationAddressKey] as? String ?? ""
        let aTypeOfCollecting = FCTypeOfCollecting(rawValue: params[kPublicationTypeOfCollectingKey] as! Int)
        let aLatitude =  params[kPublicationlatitudeKey] as! Double
        let aLongtitude = params[kPublicationLongtitudeKey] as! Double
        let aCoordinateds = CLLocationCoordinate2D(latitude: aLatitude, longitude: aLongtitude)
        
        let startingDateInt = params[kPublicationStartingDateKey] as! Int
        let aStartingDate = NSDate(timeIntervalSince1970: NSTimeInterval(startingDateInt))
        
        let endingDateInt = params[kPublicationEndingDateKey] as! Int
        let aEndingDate = NSDate(timeIntervalSince1970: NSTimeInterval(endingDateInt))
        let aContactInfo = params[kPublicationContactInfoKey] as? String ?? ""
        let aVersion = params[kPublicationVersionKey] as! Int
        let aPhotoUrl = "\(aUniquId).\(aVersion).jpg"
        let publication = FCPublication(coordinates: aCoordinateds, theTitle: aTitle, endingDate: aEndingDate, typeOfCollecting: aTypeOfCollecting!, startingDate: aStartingDate, uniqueId: aUniquId, address: anAddress,  contactInfo: aContactInfo, subTitle: aSubTitle, version: aVersion)
        return publication

    }
    
}

