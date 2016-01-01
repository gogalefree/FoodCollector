//
//  FCModel.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import CoreLocation
import Foundation

let kRecievedNewDataNotification                  = "RecievedNewDataNotification"
let kRecievedNewPublicationNotification           = "RecievedNewPublicationNotification"
let kDeletedPublicationNotification               = "DeletedPublicationNotification"
let kRecivedPublicationReportNotification         = "RecivedPublicationReportNotification"
let kRecievedPublicationRegistrationNotification  = "kRecievedPublicationRegistrationNotification"
let kNewUserCreatedPublicationNotification        = "newUserCreatedPublicationNotification"
let kDidDeleteOldVersionsOfUserCreatedPublication = "DidDeleteOldVersionsOfUserCreatedPublication"
let kDidReportDeviceUUIDToServer                  = "kDidReportDeviceUUIDToServer"
let kDeviceUUIDKey                                = "seviceUUIDString"
   
   
let kDistanceFilter = 5.0
let kModifyCoordsToPresentOnMapView = 0.0004

public class FCModel : NSObject, CLLocationManagerDelegate {
    
    var readyToLaunchUI:Bool = false
    var foodCollectorWebServer:FCServerProtocol!
    
    var publications = [FCPublication]()
    var userCreatedPublications = [FCPublication]()
    
    var fetchedPublications = [FCPublication]()
    var publicationsToDelete = [FCPublication]()
    var newPublications = [FCPublication]()
    
    var userLocation = CLLocation()
    let locationManager = CLLocationManager()
    let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingString("/publications")
    let userCreatedPublicationsFilePath = FCModel.documentsDirectory().stringByAppendingString("/userCreatedPublications")
    var photosDirectoryUrl : NSURL = FCModel.preparePhotosDirectory()
    var dataUpdater = DataUpdater()
    var uiReadyForNewData: Bool = false {
        
        didSet {
            if (uiReadyForNewData){
                print("ready for new data")
                self.downloadData()
                FCUserNotificationHandler.sharedInstance.resendPushNotificationToken()
            }
        }
    }
    
    var deviceUUID: String? = {
        var uuid = NSUserDefaults.standardUserDefaults().objectForKey(kDeviceUUIDKey) as? String
        print("has uuid already: \(uuid)")
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
            print("srver url **************: \n\(urlString)")
            
        }
        else {
            urlString = ""
            print("srver url **************: NOT FOUND")
            
        }
        return urlString
    }()
    
    public func setUp () {
        
        //we start with loading the current data
        User.sharedInstance
        loadPublications()
        loadUserCreatedPublications()
        reportDeviceUUIDToServer()
        self.dataUpdater.startUpdates()
        
        //TODO: Load User class
        
        if CLLocationManager.locationServicesEnabled() {
           self.setupLocationManager()
        }
    }
    
    func reportDeviceUUIDToServer() {
        
        if self.deviceUUID == nil {
            let uuid = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: kDeviceUUIDKey)
        }
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(kDidReportDeviceUUIDToServer) && self.deviceUUID != nil {
            self.foodCollectorWebServer.reportDeviceUUID(self.deviceUUID!)
        }
    }
    
    //initiated by delete push notification
    func prepareToDeletePublication(identifier: PublicationIdentifier) {
        
        if let publication = self.publicationWithIdentifier(identifier) {
            
            if publication.didRegisterForCurrentPublication {
                //only if registered
                //inform the tab bar to present an alert
                FCUserNotificationHandler.sharedInstance.removeLocationNotification(publication)
                let userInfo = ["publication" : publication]
                NSNotificationCenter.defaultCenter().postNotificationName("prepareToDelete", object: nil, userInfo: userInfo)
            }
            self.deletePublication(identifier, deleteFromServer: false, deleteUserCreatedPublication: false)
        }
    }
    
    func deletePublication(publicationIdentifier: PublicationIdentifier, deleteFromServer: Bool, deleteUserCreatedPublication: Bool) {
        //delete the publication
        for (index , publication) in self.publications.enumerate() {
            if publication.uniqueId == publicationIdentifier.uniqueId &&
                publication.version == publicationIdentifier.version{
                    self.publications.removeAtIndex(index)
                    self.postDeletedPublicationNotification(publicationIdentifier)
                    //save data
                    self.savePublications()
                    break
            }
        }
        //delete the publication from user created publications
        
        var publicationToDeletePhoto: FCPublication? = nil
        
        if deleteUserCreatedPublication {
            for (index , publication) in self.userCreatedPublications.enumerate() {
                if publication.uniqueId == publicationIdentifier.uniqueId &&
                    publication.version == publicationIdentifier.version{
                        publicationToDeletePhoto = publication
                        self.userCreatedPublications.removeAtIndex(index)
                        self.saveUserCreatedPublications()
                        break
                }
            }
        }

        if deleteFromServer {
            
            //delete from aws
            if let publication = publicationToDeletePhoto {
                let photofetcher = FCPhotoFetcher()
                photofetcher.deletePhotoForPublication(publication)
            }
           
            //delete from server
            self.foodCollectorWebServer.deletePublication(publicationIdentifier, completion: { (success) -> () in
          
            //TODO: implement persistency so we'll save the identifier and try again
//            if !success {
//                self.deletePublication(publicationIdentifier)
//            }
            
            
            })
            
        }
    }
    
    /// add a Publication to Publications array
    
    func addPublication(recievedPublication: FCPublication) {
        //remove older versions
        if recievedPublication.version > 1 {
            for (index, publication) in self.publications.enumerate() {
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
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.postNewUserCreatedPublicationNotification()
            })
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
            for (index, publication) in self.userCreatedPublications.enumerate() {
                
                if publication.uniqueId == userCreatedPublication.uniqueId &&
                    publication.version < userCreatedPublication.version {
                       indexesToRemove.append(index)
                        //delete photo from aws
                        let fetcher = FCPhotoFetcher()
                        fetcher.deletePhotoForPublication(publication)
                }
            }
           
            for (i ,index) in indexesToRemove.enumerate() {
                
                self.userCreatedPublications.removeAtIndex(index - i)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.saveUserCreatedPublications()
                self.postDeleteOldVersionOfUserCreatedPublications()
            })
        })
    }
    
    func addPublicationReport(report: FCOnSpotPublicationReport, identifier: PublicationIdentifier) {
        
        let possiblePublication = self.publicationWithIdentifier(identifier)
        if possiblePublication != nil {
            
            possiblePublication!.reportsForPublication.append(report)
            self.postRecivedPublicationReportNotification()
        }
    }
    
    func didRecievePublicationRegistration(registration: FCRegistrationForPublication) {
        
        let userCreatedPublication = self.userCreatedPublicationWithIdentifier(registration.identifier)

        if let userPublication = userCreatedPublication {
            userPublication.registrationsForPublication.append(registration)
            userPublication.countOfRegisteredUsers += 1
            self.saveUserCreatedPublications()
        }
        
        let possiblePublication: FCPublication? = self.publicationWithIdentifier(registration.identifier)
        
        if let publication = possiblePublication {
        
            publication.registrationsForPublication.append(registration)
            publication.countOfRegisteredUsers += 1
            self.postRecivedPublicationRegistrationNotification(publication)
            self.savePublications()
        }
    }
    
    func userCreatedPublicationWithIdentifier(identifier: PublicationIdentifier) -> FCPublication? {
        
        for publication in self.userCreatedPublications {
            if publication.uniqueId == identifier.uniqueId &&
                publication.version == identifier.version{
                    return publication
            }
        }

        return nil
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
    
    func addRegisterationFor(publication: FCPublication) {
        
        let identifier = PublicationIdentifier(uniqueId: publication.uniqueId, version: publication.version)
        let registration = FCRegistrationForPublication(
            identifier      :identifier,
            dateOfOrder     :NSDate(),
            contactInfo     :User.sharedInstance.userPhoneNumber ?? "",
            collectorName   :User.sharedInstance.userIdentityProviderUserName ?? "",
            uniqueId        :0)
        publication.registrationsForPublication.append(registration)
        self.savePublications()
    }
    
    func removeRegistrationFor(publication: FCPublication) {
        if publication.registrationsForPublication.count > 0{
            publication.registrationsForPublication.removeLast()
            self.savePublications()
        }
    }
}


// MARK: SingleTone

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

// MARK: Documents directory

public extension FCModel {
    
    public class func documentsDirectory() -> String {
        
        var doucuments = ""
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
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
            do {
                try fm.createDirectoryAtURL(photosDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        print(photosDirectoryUrl.path)
        return photosDirectoryUrl
    }
}
