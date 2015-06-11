//
//  FCModel.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import CoreLocation
import Foundation

let kRecievedNewDataNotification =                  "RecievedNewDataNotification"
let kRecievedNewPublicationNotification =           "RecievedNewPublicationNotification"
let kDeletedPublicationNotification =               "DeletedPublicationNotification"
let kRecivedPublicationReportNotification =         "RecivedPublicationReportNotification"
let kRecievedPublicationRegistrationNotification =  "kRecievedPublicationRegistrationNotification"
let kNewUserCreatedPublicationNotification =        "newUserCreatedPublicationNotification"
let kDidDeleteOldVersionsOfUserCreatedPublication = "DidDeleteOldVersionsOfUserCreatedPublication"

let kDeviceUUIDKey = "seviceUUIDString"
let kDistanceFilter = 5.0
let kModifyCoordsToPresentOnMapView = 0.0004

public class FCModel : NSObject, CLLocationManagerDelegate {
    
    var readyToLaunchUI:Bool = false
    var foodCollectorWebServer:FCServerProtocol!
    
    var publications = [FCPublication]()
    var userCreatedPublications = [FCPublication]()
    
    var fetchedPublications = [FCPublication]()
    var publicationsToDelete = [FCPublication]()
    var publicationsToAdd = [FCPublication]()
    
    var userLocation = CLLocation()
    let locationManager = CLLocationManager()
    let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("publications")
    let userCreatedPublicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("userCreatedPublications")
    var photosDirectoryUrl : NSURL = FCModel.preparePhotosDirectory()
    var dataUpdater = DataUpdater()
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
    
    var baseUrl: String = {
     
        var baseUrlPlist: NSDictionary?
        var urlString: String
        
        if let path = NSBundle.mainBundle().pathForResource("BaseURL", ofType:"plist") {
            
            baseUrlPlist = NSDictionary(contentsOfFile: path)
        }
        
        if let urlDict = baseUrlPlist {
            
            urlString = urlDict["Server URL"] as! String
            println("srver url **************: \n\(urlString)")
            
        }
        else {
            urlString = ""
            println("srver url **************: NOT FOUND")
            
        }
        return urlString
    }()
    
    public func setUp () {
        
        //we start with loading the current data
        loadPublications()
        loadUserCreatedPublications()
        self.deviceUUID ?? {
            var uuid = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: kDeviceUUIDKey)
            self.foodCollectorWebServer.reportDeviceUUID(uuid)
            return uuid
            }()
        
        self.dataUpdater.startUpdates()
        
        if CLLocationManager.locationServicesEnabled() {
           self.setupLocationManager()
        }
    }
    
    func prepareToDeletePublication(identifier: PublicationIdentifier) {
        
        if let publication = self.publicationWithIdentifier(identifier) {
            
            if publication.didRegisterForCurrentPublication {
                //only if registered
                //inform the tab bar to present an alert
                FCUserNotificationHandler.sharedInstance.removeLocationNotification(publication)
                let userInfo = ["publication" : publication]
                NSNotificationCenter.defaultCenter().postNotificationName("prepareToDelete", object: nil, userInfo: userInfo)
            }
            self.deletePublication(identifier)          
        }
    }
    
    func deletePublication(publicationIdentifier: PublicationIdentifier) {
        for (index , publication) in enumerate(self.publications) {
            if publication.uniqueId == publicationIdentifier.uniqueId &&
                publication.version == publicationIdentifier.version{
                    self.publications.removeAtIndex(index)
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
            
            //save the new data
            self.savePublications()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.postRecievedNewPublicationNotification()
            })
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
    
    func isUserCreaetedPublication(publication: FCPublication) -> Bool {
        
        for userCreatedPublication in self.userCreatedPublications {
            if publication.uniqueId == userCreatedPublication.uniqueId &&
                publication.version == userCreatedPublication.version{
                    return true
            }
        }
        return false
    }
    
    final func deleteOldVersionsOfUserCreatedPublication(userCreatedPublication: FCPublication) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            var indexesToRemove = [Int]()
            for (index, publication) in enumerate(self.userCreatedPublications) {
                
                if publication.uniqueId == userCreatedPublication.uniqueId &&
                    publication.version < userCreatedPublication.version {
                       indexesToRemove.append(index)
                }
            }
           
            for (i ,index) in enumerate(indexesToRemove) {
                
                self.userCreatedPublications.removeAtIndex(index - i)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.postDeleteOldVersionOfUserCreatedPublications()
            })
        })
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
    
       //MARK: - User registered publications
    func userRegisteredPublications() -> [FCPublication] {
        
        var userRegisteredPublications = [FCPublication]()
        
        for publication in self.publications {
            if publication.didRegisterForCurrentPublication {
                userRegisteredPublications.append(publication)
            }
        }
        return userRegisteredPublications
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
