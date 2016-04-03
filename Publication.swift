//
//  Publication.swift
//  FoodCollector
//
//  Created by Guy Freedman on 27/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Publication: NSManagedObject {

    
 //   var wasUpdated: Bool = false
    
    var coordinate: CLLocationCoordinate2D! { get {
            return CLLocationCoordinate2DMake(self.latitude!.doubleValue, self.longitutde!.doubleValue)}
    }
    
    var photoUrl: String { get {
        
        return "\(uniqueId).\(version).jpg"}
    }

    var  distanceFromUserLocation:Double { get {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distanceFromLocation(FCModel.sharedInstance.userLocation)}
    }
    
    var countOfRegisteredUsers: Int { get {
        
        guard let regsitrations = self.registrations else {return 0}
        return regsitrations.count
        }
    }
    
    var countOfRegisteredUsersAsString: String { get {
        return "\(countOfRegisteredUsers)" }
    }
    
    var audianceID: Int { get {
        
        guard let audianceInt = self.audiance else {return 0}
        return audianceInt.integerValue
        }
    }
    
    func setUserRegistration(registered: Bool) {
        
        self.didRegisterForCurrentPublication = registered
        
        if registered {
            FCUserNotificationHandler.sharedInstance.removeLocationNotification(self)
            FCUserNotificationHandler.sharedInstance.registerLocalNotification(self)
        }
        else {
            FCUserNotificationHandler.sharedInstance.removeLocationNotification(self)
        }
    }
    
    
    func updateFromParams(params: [String: AnyObject], context: NSManagedObjectContext)  {
        
        //add context
       context.performBlockAndWait { () -> Void in
            print("pubilcation params: \(params)")
            let aUniquId = params[kPublicationUniqueIdKey] as? Int ?? 0
            let aTitle = params[kPublicationTitleKey] as? String ?? ""
            let aSubTitle  = params[kPublicationSubTitleKey] as? String ?? ""
            let anAddress = params[kPublicationAddressKey] as? String ?? ""
            let aLatitude =  (params[kPublicationlatitudeKey] as? NSString)?.doubleValue ?? 0.0
            let aLongtitude = (params[kPublicationLongtitudeKey] as? NSString)?.doubleValue ?? 0.0
            
            let startingDateDouble = (params[kPublicationStartingDateKey] as? NSString)?.doubleValue ?? 0
            let startingDateInterval = startingDateDouble == 0 ? NSDate().timeIntervalSince1970 : startingDateDouble
            let aStartingDate = NSDate(timeIntervalSince1970: NSTimeInterval(startingDateInterval))
            
            let endingDateDouble = (params[kPublicationEndingDateKey] as? NSString)?.doubleValue ?? 0
            let endingDateInterval = endingDateDouble == 0 ? (NSDate().timeIntervalSince1970 + 60*24*2) : endingDateDouble
            let aEndingDate = NSDate(timeIntervalSince1970: endingDateInterval)
            
            let aContactInfo = params[kPublicationContactInfoKey] as? String ?? ""
            let aVersion = params[kPublicationVersionKey] as? Int ?? 0
            let audiance = params[kPublicationAudianceKey] as? Int ?? 0
            let publisherId = params["publisher_id"] as? Int ?? 0
            let activeDevice = params["active_device_dev_uuid"] as? String ?? ""
            let publisherUserName = params["identity_provider_user_name"] as? String ?? ""
            
            self.uniqueId = aUniquId
            self.title = aTitle
            self.subtitle = aSubTitle
            self.address = anAddress
            self.audiance = audiance
            self.latitude = NSDecimalNumber(double: aLatitude)
            self.longitutde = NSDecimalNumber(double: aLongtitude)
            self.startingData = aStartingDate
            self.endingData = aEndingDate
            self.contactInfo = aContactInfo
            self.version = aVersion
            self.publisherId = publisherId
            self.isOnAir = true
            self.publisherDevUUID = activeDevice
            self.publisherUserName = publisherUserName
            self.storedDistanceFromUserLocation = NSNumber(double: self.distanceFromUserLocation)
        
        do {
            try context.save()
        } catch {
            print("error updating publication with params \(error)")
        }
        
        
        }
    }
    
    func updateAfterUserCreation(params: [String: AnyObject], context: NSManagedObjectContext) {
        
        self.title = params[kPublicationTitleKey] as? String
        self.address = params[kPublicationAddressKey] as? String
        self.version = NSNumber(integer: params[kPublicationVersionKey] as? Int ?? 1)
        self.uniqueId = NSNumber(integer: params[kPublicationUniqueIdKey] as? Int ?? 0)
        self.audiance = NSNumber(integer: params[kPublicationAudianceKey] as? Int ?? 0)
        self.latitude = NSDecimalNumber(double: params[kPublicationlatitudeKey] as? Double ?? 0)
        self.longitutde = NSDecimalNumber(double: params[kPublicationLongtitudeKey] as? Double ?? 0)
        self.contactInfo = User.sharedInstance.userPhoneNumber
        self.typeOfCollecting = NSNumber(integer: 2)
        self.didInformServer = true
        self.isOnAir = true
        self.publisherDevUUID = FCModel.sharedInstance.deviceUUID
        self.publisherId = NSNumber(integer: User.sharedInstance.userUniqueID)
        self.publisherUserName = User.sharedInstance.userIdentityProviderUserName
        self.subtitle = params[kPublicationSubTitleKey] as? String ?? ""
        self.storedDistanceFromUserLocation = NSNumber(double: self.distanceFromUserLocation)
        self.registrations = Set<PublicationRegistration>()
        self.reports = Set<PublicationReport>()
        
        let endingDateDouble = params[kPublicationEndingDateKey] as? Double ?? 0
        self.endingData = NSDate(timeIntervalSince1970: endingDateDouble)
        
        let startingDateDouble = params[kPublicationStartingDateKey] as? Double ?? 0
        self.startingData = NSDate(timeIntervalSince1970: startingDateDouble)
    
        do {
            try context.save()
        } catch {
            print ("error updating after creation \(error)" + #function)
        }
    }
    
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        self.storedDistanceFromUserLocation = NSNumber(double: distanceFromUserLocation)
    }
    
    func toString() {
        
            print("Publication before fetch")
            print("title: \(self.title!)")
            print("starting date: \(self.startingData!.description)")
            print("ending date: \(self.endingData!.description)")
            print("on air: \(self.isOnAir?.description)")
            print("longitude : \(self.coordinate.longitude)")
            print("latitude : \(self.coordinate.latitude)")
            print("=====END=====")
        
    }
}
