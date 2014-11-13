//
//  FCModel.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import CoreLocation
import Foundation

public class FCModel : NSObject {
    
    var locationManager = CLLocationManager()
    var appDataStoreManager = FCAppDataStoreManager()
    var readyToLaunchUI:Bool = false
    var foodCollectorWebServer:FCServerProtocol!
    public var publications = [FCPublication]()
    var pushNotificationHandler = FCUserNotificationHandler()
    var userCreatedPublications = [FCPublication]()
    var userLocation = CLLocation()
    let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("publications")
    let userCreatedPublicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("userCreatedPublications")
    
    ///
    ///loads publications from disk and fetches data from server
    // 
    
    public func setUp () {
        
        self.foodCollectorWebServer.downloadAllPublicationsWithCompletion
            { (thePublications: [FCPublication]) -> Void in
                self.publications = thePublications
                self.savePublications()
                
                self.userCreatedPublications = thePublications
                self.saveUserCreatedPublications()
        }
    }
    
    ///
    ///posts NSNotification when the downloaded data is ready
    ///
    
    func postFetchedDataReadyNotification () {
        
        
    }
    
    /// removes a Publication to Publications array
    ///
    
    func removePublication(arg1:AnyObject) {
        
    }
    
    ///
    /// add a Publication to Publications array
    ///
    
    func addPublication(arg1:AnyObject) {
        
    }
    
    ///
    /// called after init when all data was successfully fetched from the server
    
    
    func postApplicationDataDidChangeNotification() {
        
    }
    
}

// MARK - store

public extension FCModel {
    
    func savePublications() {
        
        let success = NSKeyedArchiver.archiveRootObject(self.publications, toFile: self.publicationsFilePath)
    }
    
    func loadPublications() {
        
        let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.publicationsFilePath) as [FCPublication]
        self.publications = array
    }
    
    func saveUserCreatedPublications() {
        
        let success = NSKeyedArchiver.archiveRootObject(self.publications, toFile: self.userCreatedPublicationsFilePath)
    }
    
    func loadUserCreatedPublicationsPublications() {
        
        let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.userCreatedPublicationsFilePath) as [FCPublication]
        self.userCreatedPublications = array
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
