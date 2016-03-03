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
let kReloadDataNotification                       = "kReloadDataNotification"
   
let kDistanceFilter = 5.0
let kModifyCoordsToPresentOnMapView = 0.0004

public class FCModel : NSObject, CLLocationManagerDelegate {
    
    static let dataController = DataController()
    
    var readyToLaunchUI:Bool = false
    var foodCollectorWebServer:FCServerProtocol!
    
    var publications = [Publication]()
    var userCreatedPublications = [Publication]()

    
    //this is set whenever a user deletes a userCreatedPublication
    //ui can get the deleted object here
    var userDeletedPublication: Publication?
    
    var userLocation = CLLocation()
    let locationManager = CLLocationManager()
    var photosDirectoryUrl : NSURL = FCModel.preparePhotosDirectory()
    var dataUpdater = DataUpdater()
    var uiReadyForNewData: Bool = false {
        
        didSet {
            if (uiReadyForNewData){
            
                self.foodCollectorWebServer.downloadAllPublications()
                FCUserNotificationHandler.sharedInstance.resendPushNotificationToken()
            }
        }
    }
    
    var deviceUUID: String? = NSUserDefaults.standardUserDefaults().objectForKey(kDeviceUUIDKey) as? String
    
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
        
        if CLLocationManager.locationServicesEnabled() {
           self.setupLocationManager()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mergeChanges:", name: NSManagedObjectContextDidSaveNotification, object: nil)
        
    }
    
    func mergeChanges(notification: NSNotification) {
    
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            FCModel.dataController.managedObjectContext.performBlock({ () -> Void in
                let moc = FCModel.dataController.managedObjectContext
                moc.mergeChangesFromContextDidSaveNotification(notification)
                FCModel.sharedInstance.postReloadDataNotificationOnMainThread()
                
            })
        }
    }
    
    func reportDeviceUUIDToServer() {
        
        if self.deviceUUID == nil {
            let uuid = NSUUID().UUIDString
            self.deviceUUID = uuid
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: kDeviceUUIDKey)
        }
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(kDidReportDeviceUUIDToServer) && self.deviceUUID != nil {
            self.foodCollectorWebServer.reportDeviceUUID(self.deviceUUID!)
        }
    }
    
    //initiated by delete push notification
    func prepareToDeletePublication(identifier: PublicationIdentifier) {
        
//        if let publication = self.publicationWithIdentifier(identifier) {
//            
//            if publication.didRegisterForCurrentPublication {
//                //only if registered
//                //inform the tab bar to present an alert
//                FCUserNotificationHandler.sharedInstance.removeLocationNotification(publication)
//                let userInfo = ["publication" : publication]
//                NSNotificationCenter.defaultCenter().postNotificationName("prepareToDelete", object: nil, userInfo: userInfo)
//            }
//            self.deletePublication(identifier, deleteFromServer: false, deleteUserCreatedPublication: false)
//        }
    }
    
    func deletePublication(publication: Publication, deleteFromServer: Bool) {
        
        self.userDeletedPublication = publication
        
        //delete the publication
        let context = FCModel.dataController.managedObjectContext
        context.performBlock { () -> Void in
            context.deleteObject(publication)
            FCModel.dataController.save()
        }
        
    
        self.postDeletedPublicationNotification()
        let photofetcher = FCPhotoFetcher()
        photofetcher.deletePhotoForPublication(publication)
        if deleteFromServer {
          
            self.foodCollectorWebServer.deletePublication(publication, completion: { (success) -> () in
                
                //TODO: implement persistency so we'll save the identifier and try again
                
            })
        }
    }
    
    /// add a Publication to Publications array
    
    func addPublication(recievedPublication: Publication) {
        
        
            //append the new publication
            self.publications.append(recievedPublication)
        
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.postRecievedNewPublicationNotification()
            })
    }
    
    
    func addUserCreatedPublication(publication: Publication) {
       
        self.userCreatedPublications.append(publication)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.postNewUserCreatedPublicationNotification()
            })
    }
    
    


    
    func addRegisterationFor(publication: Publication) {
        
        let context = FCModel.dataController.managedObjectContext
        context.performBlock { () -> Void in
            
            guard let registration = PublicationRegistration.registrationForPublication(publication, context: context) else {return}
            FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(registration , completion: {(success) in
            
                if success {
                    
                    FCModel.dataController.save()
                }
            
            })

        }
    }
    
    func removeRegistrationFor(publication: Publication) {
        
        FCModel.sharedInstance.foodCollectorWebServer.unRegisterUserFromComingToPickUpPublication(publication, completion: { (success) -> Void in})
        guard let registrations = publication.registrations else {return}
        let predicate = NSPredicate(format: "collectorUserId = %@", NSNumber(integer: User.sharedInstance.userUniqueID))
        let userRegistrations = registrations.filteredSetUsingPredicate(predicate)
        if userRegistrations.count > 0{
            let set = NSMutableSet(set: publication.registrations!)
            let registration = set.anyObject() as! PublicationRegistration
            set.removeObject(registration)
            publication.registrations = set

            let context = FCModel.dataController.managedObjectContext
            context.performBlock({ () -> Void in
                context.deleteObject(registration)
                FCModel.dataController.save()
            })
            
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
