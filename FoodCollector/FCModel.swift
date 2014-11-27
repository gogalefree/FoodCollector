//
//  FCModel.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import CoreLocation
import Foundation

let kRecievedNewDataNotification = "RecievedNewDataNotification"
let kRecievedNewPublicationNotification = "RecievedNewPublicationNotification"
let kDeletedPublicationNotification = "DeletedPublicationNotification"
let kRecivedPublicationReportNotification = "RecivedPublicationReportNotification"
let kRecievedPublicationRegistrationNotification = "kRecievedPublicationRegistrationNotification"
let kDeviceUUIDKey = "seviceUUIDString"
let kDistanceFilter = 1.0

public class FCModel : NSObject, CLLocationManagerDelegate {
    
    var appDataStoreManager = FCAppDataStoreManager()
    var readyToLaunchUI:Bool = false
    var foodCollectorWebServer:FCServerProtocol!
    public var publications = [FCPublication]()
    var userCreatedPublications = [FCPublication]()
    var userLocation = CLLocation()
    let locationManager = CLLocationManager()
    let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("publications")
    let userCreatedPublicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("userCreatedPublications")
    var uiReadyForNewData: Bool = false {

        didSet {
            if (uiReadyForNewData){
                println("ready for new data")
                self.downloadData()
            }
        }
    }
    
    var deviceUUID: String? = {
       var uuid = NSUserDefaults.standardUserDefaults().objectForKey(kDeviceUUIDKey) as? String
        println("has uuid already: \(uuid)")
        return uuid
    }()
    
    public func setUp () {
        
        //we start with loading the current data
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kDistanceFilter
        self.locationManager.startUpdatingLocation()

        self.loadPublications()
        self.loadUserCreatedPublicationsPublications()
        self.deviceUUID ?? {
            var uuid = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: kDeviceUUIDKey)
            self.foodCollectorWebServer.reportDeviceUUID(uuid)
            return uuid
        }()
    }
    
    func downloadData() {
        self.foodCollectorWebServer.downloadAllPublicationsWithCompletion
            { (thePublications: [FCPublication]) -> Void in
         
                self.publications = thePublications
                self.postFetchedDataReadyNotification()
            //    self.savePublications()
              
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            println("always")
        case .AuthorizedWhenInUse:
            println("in use")
        case .NotDetermined:
            println("not determind")
        case .Denied:
            println("denied")
        case .Restricted:
            println("restrivted")


        }
        println("Did change authorization \(status)")
    }
    /// deletes a Publication to Publications array
    ///
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        self.userLocation = locations.first as CLLocation
    }

    
    func deletePublication(publicationIdentifier: PublicationIdentifier) {
        for (index , publication) in enumerate(self.publications) {
            if publication.uniqueId == publicationIdentifier.uniqueId &&
                publication.version == publicationIdentifier.version{
                    self.publications.removeAtIndex(index)
                    FCUserNotificationHandler.sharedInstance.removeLocationNotification(publication)
                    self.postDeletedPublicationNotification(publicationIdentifier)
                    //save data
                    //self.savePublications()
                    break
            }
        }
    }
    
    /// add a Publication to Publications array
    
    func addPublication(recievedPublication: FCPublication) {
        //remove older versions
        if recievedPublication.version > 1 {
            for (index, publication) in enumerate(self.publications) {
                if publication.uniqueId == recievedPublication.uniqueId &&
                    publication.version < recievedPublication.version {
                        self.publications.removeAtIndex(index)
                        FCUserNotificationHandler.sharedInstance.removeLocationNotification(publication)
                        break
                }
            }
        }
        //append the new publication
        self.publications.append(recievedPublication)
        FCUserNotificationHandler.sharedInstance.registerLocalNotification(recievedPublication)
        self.postRecievedNewPublicationNotification()

        //save the new data
        //self.savePublications()
    }
    
    func addPublicationReport(report: FCOnSpotPublicationReport, identifier: PublicationIdentifier) {
        
        var possiblePublication = self.publicationWithIdentifier(identifier)
        if possiblePublication != nil {
            
            possiblePublication!.reportsForPublication.append(report)
            self.postRecivedPublicationReportNotification()
        }
    }
    
    func didRecievePublicationRegistration(registration: FCRegistrationForPublication) {
       
        var possiblePublication: FCPublication? = self.publicationWithIdentifier(registration.identifier)
        
        if possiblePublication != nil {
        
            switch registration.registrationMessage {
                case .register:
                    possiblePublication!.registrationsForPublication.append(registration)
                case .unRegister:
                    for (index, aRegistration) in enumerate(possiblePublication!.registrationsForPublication){
                        if aRegistration.dateOfOrder == registration.dateOfOrder {
                            possiblePublication!.registrationsForPublication.removeAtIndex(index)
                        }
                    }
                default:
                    break
            }
            self.postRecivedPublicationRegistrationNotification()
        }
    }
    
    func publicationWithIdentifier(identifier: PublicationIdentifier) -> FCPublication? {
        var requestedPublication: FCPublication?
        for publication in self.publications {
            if publication.uniqueId == identifier.uniqueId &&
                publication.version == identifier.version{
                requestedPublication = publication
            }
        }
        return requestedPublication
    }
    ///posts NSNotification when the downloaded data is ready
    
    
    func postFetchedDataReadyNotification () {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecievedNewDataNotification, object: self)
    }
    
    //posts after the new publication recived from push was added to the model
    func postRecievedNewPublicationNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecievedNewPublicationNotification, object: self)
    }
    
    //posts after the deleted publication from push was removed from the model
    func postDeletedPublicationNotification(publicationIdentifier: PublicationIdentifier) {
        NSNotificationCenter.defaultCenter().postNotificationName(kDeletedPublicationNotification, object: self)
    }
    
    func postRecivedPublicationReportNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecivedPublicationReportNotification, object: self)
    }
    
    func postRecivedPublicationRegistrationNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecievedPublicationRegistrationNotification, object: self)
    }
}

// MARK - store

public extension FCModel {
    
    func savePublications() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let success = NSKeyedArchiver.archiveRootObject(self.publications, toFile: self.publicationsFilePath)
        }
    }
    
    func loadPublications() {
        
        if NSFileManager.defaultManager().fileExistsAtPath(self.publicationsFilePath){
            let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.publicationsFilePath) as [FCPublication]
            self.publications = array
        }
    }
    
    func saveUserCreatedPublications() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let success = NSKeyedArchiver.archiveRootObject(self.publications, toFile: self.userCreatedPublicationsFilePath)
        }
    }
    
    func loadUserCreatedPublicationsPublications() {
        
        if NSFileManager.defaultManager().fileExistsAtPath(self.userCreatedPublicationsFilePath){
            
            let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.userCreatedPublicationsFilePath) as [FCPublication]
            self.userCreatedPublications = array
        }
    }
}

// MARK - singleTone

public extension FCModel {

        //SingleTone Shared Instance
        public class var sharedInstance : FCModel {
            
            struct Static {
                static var onceToken : dispatch_once_t = 0
                static var instance : FCModel? = nil
            }
            
            dispatch_once(&Static.onceToken) {
                Static.instance = FCModel()
            }
            
            return Static.instance!
        }
}

// MARK - documents directory

public extension FCModel {
    
    public class func documentsDirectory() -> String {
        
        var doucuments = ""
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if  dirs != nil {
            doucuments = dirs![0]
        }
        return doucuments
    }
}
