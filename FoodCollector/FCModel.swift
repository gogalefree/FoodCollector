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
    
    let dataController = DataController()
    
    var processingData = false
    
    var foodCollectorWebServer:FCServerProtocol!
    
    var publications = [Publication]()
    var userCreatedPublications = [Publication]()

    var shouldPresentAddItem = false
    var shouldPresentNearYouItem = false
    
    //this is set whenever a user deletes a userCreatedPublication or when a delete remote notification arrives
    //ui can get the deleted object here
    var userDeletedPublication: Publication?
    
    var userLocation = CLLocation()
    let locationManager = CLLocationManager()
    var photosDirectoryUrl : NSURL = FCModel.preparePhotosDirectory()
    var dataUpdater = DataUpdater()
    var uiReadyForNewData: Bool = false {
        
        didSet {
            if (uiReadyForNewData){
            
                  //  self.foodCollectorWebServer.downloadAllPublications()
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
        self.foodCollectorWebServer.downloadAllPublications()
        self.dataUpdater.startUpdates()
        self.locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
           self.setupLocationManager()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FCModel.mergeChanges(_:)), name: NSManagedObjectContextDidSaveNotification, object: nil)
        
    }
    
    func mergeChanges(notification: NSNotification) {
    
        let moc = notification.object as? NSManagedObjectContext
        if let callerMoc = moc {
            if callerMoc == FCModel.sharedInstance.dataController.managedObjectContext {
//                callerMoc.mergeChangesFromContextDidSaveNotification(notification)
                print("SAME CONTEXT")
                return
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            FCModel.sharedInstance.dataController.managedObjectContext.performBlock({ () -> Void in
                let moc = FCModel.sharedInstance.dataController.managedObjectContext
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
    
    
    func deletePublication(publication: Publication, deleteFromServer: Bool) {
        
        self.userDeletedPublication = publication
        
        //delete the publication
        let context = FCModel.sharedInstance.dataController.managedObjectContext
        context.performBlockAndWait { () -> Void in
            context.deleteObject(publication)
            FCModel.sharedInstance.dataController.save()
            self.loadPublications()
            self.loadUserCreatedPublications()
        }
        
    
        let photofetcher = FCPhotoFetcher()
        photofetcher.deletePhotoForPublication(publication)
        if deleteFromServer {
          
            self.foodCollectorWebServer.deletePublication(publication, completion: { (success) -> () in
                
                //TODO: implement persistency so we'll save the identifier and try again
                
            })
        }
        
        else {
            //we post this notification if the delete came from a push notification and not if the user deleted
            self.postDeletedPublicationNotification()
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
               // self.postNewUserCreatedPublicationNotification()
            })
    }
    
    


    
    func addRegisterationFor(publication: Publication) {
        
        let context = FCModel.sharedInstance.dataController.managedObjectContext
        context.performBlock { () -> Void in
            
            guard let registration = PublicationRegistration.registrationForPublication(publication, context: context) else {return}
            FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(registration , completion: {(success) in
            
                if success {
                    
                    FCModel.sharedInstance.dataController.save()
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

            let context = FCModel.sharedInstance.dataController.managedObjectContext
            context.performBlock({ () -> Void in
                context.deleteObject(registration)
                FCModel.sharedInstance.dataController.save()
            })
            
        }
    }
    
    func publicationWithUniqueId(identifier: PublicationIdentifier) -> Publication? {
        
        let request = NSFetchRequest(entityName: kPublicationEntity)
        let predicate = NSPredicate(format: "uniqueId = %@", NSNumber(integer: identifier.uniqueId))
        request.predicate = predicate
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        do {
        
            let results = try moc.executeFetchRequest(request) as! [Publication]
            if results.count > 0 { return results.last! } else {return nil}
            
            
        } catch { return nil }
    }
    
    func publicationsForUser() -> [Publication]? {
        
        let moc = self.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: kPublicationEntity)
        request.predicate = NSPredicate(format: "audiance != %@", NSNumber(integer: 0))
        
        var results: [Publication]? = nil
        
        do {
           
            results = try moc.executeFetchRequest(request) as? [Publication]
        } catch {
            print(error)
        }
        
        return results
    }
    
    func userDidLogout() {
        
        deleteUserPublications()
    }
    
    func deleteUserPublications(){
        let moc = dataController.managedObjectContext
        moc.performBlock {
            
            let userPublications = self.publicationsForUser()
            guard let toDelete = userPublications else {return}
            for publication in toDelete {
                moc.deleteObject(publication)
            }
        }
    }

    
    func deleteDataForGroup(group: Group) {
    
        let groupId = group.id?.integerValue ?? 0
        let moc = self.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: kPublicationEntity)
        request.predicate = NSPredicate(format: "audiance = %@", NSNumber(integer:groupId))
        moc.performBlock { 
            
            moc.deleteObject(group)
            do {
                let results = try moc.executeFetchRequest(request) as? [Publication]
                guard let arrayToDelete = results else {
                    self.dataController.save()
                    return
                }
                
                for publication in arrayToDelete {
                    moc.deleteObject(publication)
                }
                
                self.dataController.save()
                
                
            }catch let error as NSError {
                print("error deleting group data after group deletion \(error.description) \(#function)")
            }
            
        }
        
        FCModel.sharedInstance.dataController.save()
        
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
