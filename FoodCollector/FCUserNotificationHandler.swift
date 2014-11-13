//
//  FCUserNotificationHandler.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
//  SingleTone

import Foundation

///
/// Handles user notifications logic. location and remote notifications.
///
class FCUserNotificationHandler : NSObject {
    
    var registeredPublications: [FCPublication]?
    
    
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
    func registerForPushNotificationWithToken(deviceId:String) {
        
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


