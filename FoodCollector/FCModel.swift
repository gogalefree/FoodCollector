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
let kNewUserCreatedPublicationNotification = "newUserCreatedPublicationNotification"

let kDeviceUUIDKey = "seviceUUIDString"
let kDistanceFilter = 5.0

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
    var photosDirectoryUrl : NSURL = FCModel.preparePhotosDirectory()
    var uiReadyForNewData: Bool = false {
        
        didSet {
            if (uiReadyForNewData){
                println("ready for new data")
                self.downloadData()
                FCUserNotificationHandler.sharedInstance.resendPushNotificationToken()
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
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kDistanceFilter
        self.locationManager.startUpdatingLocation()
        
        
        loadPublications()
        loadUserCreatedPublications()
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
                //uncomment AFTER first build
                self.savePublications()
                self.downloadReportsForPublications()
                self.postFetchedDataReadyNotification()
                
                //uncomment to simulate user created publication from mock data
                
               /* self.userCreatedPublications.append(thePublications[0])
                self.userCreatedPublications.append(thePublications[1])
                self.userCreatedPublications.append(thePublications[2])
                self.userCreatedPublications.append(thePublications[3])
                self.userCreatedPublications.append(thePublications[4])
                self.userCreatedPublications.append(thePublications[5])
                */
                /*
                // uncomment FOR first build only
                self.userCreatedPublications.removeAll(keepCapacity: false)
                self.userCreatedPublications.append(thePublications[0])
                self.userCreatedPublications.append(thePublications[1])
                self.userCreatedPublications.append(thePublications[2])
                self.saveUserCreatedPublications()
                */
                
        }
    }
    
    func downloadReportsForPublications() {
        
        let counter = self.publications.count - 1
        
        for (index ,publication) in enumerate(self.publications) {
            self.foodCollectorWebServer.reportsForPublication(publication, completion: { (success: Bool, reports: [FCOnSpotPublicationReport]?) -> () in
                if success {
                    publication.reportsForPublication = reports!
                    publication.countOfRegisteredUsers = reports!.count
                }
                if index == counter {
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchNewPublicationReportNotification", object: self)
                }
            })
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
                    self.savePublications()
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
        
        if !publicationExists(recievedPublication){
            //append the new publication
            self.publications.append(recievedPublication)
            FCUserNotificationHandler.sharedInstance.registerLocalNotification(recievedPublication)
            self.postRecievedNewPublicationNotification()
        
            //save the new data
            self.savePublications()
        }
    }
    
    func publicationExists(publication: FCPublication) -> Bool{
        var exists = false
        for existingPublication in self.publications {
            if publication.uniqueId == existingPublication.uniqueId &&
                publication.version == existingPublication.version {
                    exists = true
                    break
            }
        }
        return exists
    }
    
    func addUserCreatedPublication(publication: FCPublication) {
        if !userCreatedPublicationExists(publication){
            self.userCreatedPublications.append(publication)
            self.postNewUserCreatedPublicationNotification()
            self.saveUserCreatedPublications()
        }
    }
    
    func userCreatedPublicationExists(publication: FCPublication) -> Bool {
        var exists = false
        for existingPublication in self.userCreatedPublications {
            if existingPublication.version == publication.version &&
                existingPublication.uniqueId == publication.uniqueId {
                    exists = true
                    break
            }
        }
        return exists
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
                possiblePublication?.registrationsForPublication.append(registration)
                possiblePublication?.countOfRegisteredUsers += 1
            case .unRegister:
                for (index, aRegistration) in enumerate(possiblePublication!.registrationsForPublication){
                    if aRegistration.dateOfOrder == registration.dateOfOrder {
                        possiblePublication?.registrationsForPublication.removeAtIndex(index)
                        possiblePublication?.countOfRegisteredUsers -= 1
                    }
                }
            default:
                break
            }
            //publication's registrations array holds only instances with a register message.
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
    
    func postNewUserCreatedPublicationNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kNewUserCreatedPublicationNotification, object: self)
    }
    
    //MARK: - User registered publications
    func userRegisteredPublications() -> [FCPublication] {
        
        var userRegisteredPublications = [FCPublication]()
        
        for publication in self.publications {
            println("\(publication.title) is registered = \(publication.didRegisterForCurrentPublication)")
            if publication.didRegisterForCurrentPublication {
                userRegisteredPublications.append(publication)
            }
        }
        return userRegisteredPublications
    }
}

// MARK: - store

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
            let success = NSKeyedArchiver.archiveRootObject(self.userCreatedPublications, toFile: self.userCreatedPublicationsFilePath)
        }
    }
    
    func loadUserCreatedPublications() {
        
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
    
    public class func preparePhotosDirectory() -> NSURL {
        
        let fm = NSFileManager.defaultManager()
        let appSupportDirs = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let photosDirectoryUrl = appSupportDirs[0].URLByAppendingPathComponent("Images")
        
        if !photosDirectoryUrl.checkResourceIsReachableAndReturnError(nil) {
            var error: NSError?
            if !fm.createDirectoryAtURL(photosDirectoryUrl, withIntermediateDirectories: true, attributes: nil, error: &error) {
                println(error)
            }
        }
        println(photosDirectoryUrl.path)
        return photosDirectoryUrl
    }
}
