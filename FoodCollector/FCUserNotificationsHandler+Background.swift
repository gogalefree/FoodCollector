//
//  FCUserNotificationsHandler+Background.swift
//  FoodCollector
//
//  Created by Guy Freedman on 15/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreLocation

let kUserLastLatitudeKey =  "userLastLatitude"
let kUserLastLongitudeKey =  "userLastLongitude"


extension FCUserNotificationHandler {

    /*
        Called when a remote notification comes while the app is inActive
    */
    
    func handleNotificationFromBacground(userInfo: [NSObject : AnyObject]){
        
        //check if the User wants to recive notifications in his settings
        if !User.sharedInstance.settings.shouldPresentNotifications {return}
        
        //check if the notification object has the type key
        if let notificationType = userInfo[kRemoteNotificationType] as? String {
            
            let data = userInfo[kRemoteNotificationDataKey] as? [String : AnyObject] ?? ["" : ""]
            
            //we do not present notifications for group changes while in the backgroupnd
            if notificationType == kRemoteNotificationTypeGroupMembers {
            
                return
            }
            
        
            
            //location of the push event
            let notificationLatitude = data?["latitude"] as? Double ?? 0
            let notificationLongitude = data?["longitude"] as? Double ?? 0
            
            //user last location. was set in the last app shutdown
            let userLastLatitude = NSUserDefaults.standardUserDefaults().doubleForKey(kUserLastLatitudeKey) ?? 0
            let userLastLongitude = NSUserDefaults.standardUserDefaults().doubleForKey(kUserLastLongitudeKey) ?? 0
            
            //create CLLocation object to define distance
            let noiticationLocation = CLLocation(latitude: notificationLatitude, longitude: notificationLongitude)
            let userLocation = CLLocation(latitude: userLastLatitude, longitude: userLastLongitude)
            
            let distance = Int(userLocation.distanceFromLocation(noiticationLocation))
            let notificationRadiusMeters = User.sharedInstance.settings.notificationsRadius * 1000
            
            //check if the push object is within notifications radius
            if distance <= notificationRadiusMeters {
                
                let publicationTitle = data?["title"] as? String ?? ""
                let notificationTitle = titleForNotificationType(notificationType) + " " + publicationTitle
                
                //create local notification and present to the user
                let notification = UILocalNotification()
                notification.alertBody = notificationTitle // text that will be displayed in the notification
                notification.fireDate  = NSDate() // todo item due date (when notification will be fired)
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
                //unused options
                //notification.alertAction = "open"
                // assign a unique identifier to the notification so that we can retrieve it later
                //notification.userInfo = ["": "", ]
                //notification.category = "CATEGORY"
                
                //badge handling
                var badgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
                badgeNumber += 1
                UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
                
                //when the app starts - the notificationBadgeCounter Starts From here
                NSUserDefaults.standardUserDefaults().setInteger(badgeNumber, forKey: kNotificationBadgeNumberKey)

            }
        }
    }
    
    func titleForNotificationType(type: String) -> String {
        
        var activityLogType = ActivityLog.LogType.NewPublication
        
        
        switch type {
            
        case kRemoteNotificationTypeNewPublication:
            activityLogType = ActivityLog.LogType.NewPublication
            
        case kRemoteNotificationTypeDeletedPublication:
            activityLogType = ActivityLog.LogType.DeletePublication
            
        case kRemoteNotificationTypePublicationReport:
            activityLogType = ActivityLog.LogType.Report
            
        case kRemoteNotificationTypeUserRegisteredForPublication:
            activityLogType = ActivityLog.LogType.Registration
            
        default:
            break
        }
        
        return ActivityLog.titleForType(activityLogType.rawValue, publication: nil, group: nil)
    }
}