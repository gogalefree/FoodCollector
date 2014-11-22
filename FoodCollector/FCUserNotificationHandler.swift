//
//  FCUserNotificationHandler.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
//  SingleTone

import Foundation
import UIKit

let kUserNotificationShowActionId = "SHOW_IDENTIFIER"
let kRemoteNotificationType = "type"
let kRemoteNotificationTypeNewPublication = "new_publication"
let kRemoteNotificationTypeDeletedPublication = "deleted_publication"
let kRemoteNotificationTypePublicationReport = "publication_report"
let kRemoteNotificationTypeUserRegisteredForPublication = "user_registered_for_publication"
let kRemoteNotificationDataKey = "data"
///
/// Handles user notifications logic. location and remote notifications.
///
class FCUserNotificationHandler : NSObject {
    
    
    var registeredForNotifications: Bool = {
        return UIApplication.sharedApplication().currentUserNotificationSettings().types != nil
        }()
    
    var oldToken: String? = {
        return NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey) as? NSString
        }()
    
    var registeredPublicationsForLocationNotification = [FCPublication]()
    var recievedPublications = [FCPublication]()
    
    
    func didRecieveLocalNotification(notification: UILocalNotification) {
        
    }
    
    func didRecieveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
        if let notificationType = userInfo[kRemoteNotificationType] as? String {
        
            switch notificationType {
                
            case kRemoteNotificationTypeNewPublication:
                
                let newPublication = FCPublication.publicationWithParams(userInfo[kRemoteNotificationDataKey] as [String : String])
                if !self.publicationExists(newPublication) {
                    self.recievedPublications.append(newPublication)
                    FCModel.sharedInstance.addPublication(newPublication)
                }
                
                
                
            case kRemoteNotificationTypeDeletedPublication:
                
                println("delete publication notification")
                
            case kRemoteNotificationTypePublicationReport:
                
                println("publication report notification")
                
            case kRemoteNotificationTypeUserRegisteredForPublication:
                
                println("user registered for publication notification")

            default:
                    break
                
            }
            
        }
    }
    
    ///
    /// cancel action called by the show button on a notification view while the
    ///  app in background mode.
    /// app stays in backround
    ///
    func pushCancelActionForNotification(publication:[NSObject : AnyObject]) {
        
    }
    
    ///
    /// called when a new Publication push notification arrives.
    /// can be called several times for the same notification.
    ///
    func didReciveNewPublicationNotification(notification:[NSObject : AnyObject]) {
        
    }
    
    ///
    /// unregisters a location notification for all current Publications.
    /// must be called before deInit of a Publication
    ///
    func removeLocationNotifications(publications:[FCPublication]) {
        
    }
    
    ///
    /// this method receives the new token and calls the server’s reportNewTok
    /// en:oldToken:
    ///
    func registerForPushNotificationWithToken(newToken:String) {
        
        if let currentToken = self.oldToken {
            if currentToken == newToken {return}
        }
        
        FCModel.sharedInstance.foodCollectorWebServer.reportDeviceTokenForPushWithDeviceNewToken(newToken, oldtoken: self.oldToken)
        
        NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: kRemoteNotificationTokenKey)
    }
    
    ///
    /// called when a user arrives to a publication spot.
    /// called by the app as a result of user location notification
    ///
    func didArriveToPublicationSpot(publication:FCPublication) {
        
    }
    
    ///
    /// show action called by the show button on a notification view while the
    ///  app in background mode.
    /// app launches UI
    ///
    func pushShowActionForNotification(notification:[NSObject: AnyObject]) {
        
    }
    
    ///
    /// registers a location notification for all current Publications.
    ///
    func registerForLocationNotifications(publications:[FCPublication]) {
        
    }
    
    func publicationExists(incomingPublication: FCPublication) -> Bool {

        var exists = false
        for publication in self.recievedPublications {
                if publication.uniqueId == incomingPublication.uniqueId &&
                    publication.version == incomingPublication.version {
                        exists = true
                        break
            }
        }
     return exists
    }
    
}


// MARK - Setup

extension FCUserNotificationHandler {
    func setup(){
        
        let showAction = UIMutableUserNotificationAction()
        showAction.identifier = "SHOW_IDENTIFIER"
        // Localized string displayed in the action button
        showAction.title = "Show"
        // If you need to show UI, choose foreground
        showAction.activationMode = UIUserNotificationActivationMode.Foreground
        // Destructive actions display in red
        showAction.destructive = false
        // Set whether the action requires the user to authenticate
        showAction.authenticationRequired = false
        
        let cancelAction = UIMutableUserNotificationAction()
        cancelAction.identifier = "DISSMISS_IDENTIFIER"
        // Localized string displayed in the action button
        cancelAction.title = "Dissmiss"
        // If you need to show UI, choose foreground
        cancelAction.activationMode = UIUserNotificationActivationMode.Background
        // Destructive actions display in red
        cancelAction.destructive = false
        // Set whether the action requires the user to authenticate
        cancelAction.authenticationRequired = false
        
        
        let arrivedToPublicationCategory = UIMutableUserNotificationCategory()
        
        // Identifier to include in your push payload and local notification
        arrivedToPublicationCategory.identifier = "ARRIVED_CATEGORY"
        // Add the actions to the category and set the action context
        arrivedToPublicationCategory.setActions([showAction, cancelAction], forContext: UIUserNotificationActionContext.Default)
        
        
        let categoriesSet = NSSet(object: arrivedToPublicationCategory)
        let types = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound;
        
        let settings = UIUserNotificationSettings(forTypes: types, categories: categoriesSet);
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications();
    }
}

extension FCUserNotificationHandler {
    //SingleTone Shared Instance
    class var sharedInstance : FCUserNotificationHandler {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCUserNotificationHandler? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCUserNotificationHandler()
        }
        return Static.instance!
    }
}


