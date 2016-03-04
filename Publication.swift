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
            return CLLocationCoordinate2DMake(self.longitutde!.doubleValue, self.longitutde!.doubleValue)}
    }
    
    var photoUrl: String { get {
        
        return "\(uniqueId).\(version).jpg"}
    }

    var  distanceFromUserLocation:Double { get {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distanceFromLocation(FCModel.sharedInstance.userLocation)}
    }
    
    var countOfRegisteredUsers: Int { get {
        
        guard let reports = self.reports else {return 0}
        return reports.count
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
            let audiance = params["audience"] as? Int ?? 0
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
        }
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
