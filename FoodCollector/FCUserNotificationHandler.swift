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
import CoreLocation


let kUserNotificationShowActionId = "SHOW_IDENTIFIER"
let kRemoteNotificationType = "type"
let kRemoteNotificationTypeNewPublication = "new_publication"
let kRemoteNotificationTypeDeletedPublication = "deleted_publication"
let kRemoteNotificationTypePublicationReport = "publication_report"
let kRemoteNotificationPublicationReportMessageKey = "report"
let kRemoteNotificationPublicationReportDateKey = "date"
let kRemoteNotificationTypeUserRegisteredForPublication = "registration_for_publication"
let kRemoteNotificationRegistrationMessageForPublicationKey = "registration_message"
let kRemoteNotificationTypeGroupMembers = "group_members"
let kRemoteNotificationDataKey = "data"
//let kShouldShowNewPublicationFromPushNotification = "kShouldShowNewPublicationFromPushNotification"
let kRegionRadiusForLocationNotification = 20
let kDidArriveOnSpotNotification = "didArriveOnSpot"
let kNotificationBadgeNumberKey  = "kNotificationsBadgeNumber"
let kUpdateNotificationsCounterNotification = "kUpdateNotificationsCounterNotification"


class FCUserNotificationHandler : NSObject {
    
    
    var registeredForNotifications: Bool = {
        return UIApplication.sharedApplication().currentUserNotificationSettings()!.types != []
        }()
    
    var oldToken: String? = {
        print("Push TOKEN: \(NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey))")
        return NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey) as? String
        }()
    
    var notificationsBadgeCounter: Int = NSUserDefaults.standardUserDefaults().integerForKey(kNotificationBadgeNumberKey) ?? 0 {
        didSet {
            if notificationsBadgeCounter != oldValue {
                saveNotificationBadgeCounter()
                self.postUpdateNotificationCounterNotification()
                print("Notification Badge Count: \(notificationsBadgeCounter)", separator: "=========", terminator: "\n______________")
            }
        }
    }
    
    
    var registeredLocationNotification = [(UILocalNotification, Publication)]()
    
    /// this method receives the new token and calls the server’s
    /// reportNewToken:oldToken:
    
    func registerForPushNotificationWithToken(newToken:String) {
        
        if let currentToken = self.oldToken {
            if currentToken == newToken && NSUserDefaults.standardUserDefaults().boolForKey(kDidReportPushNotificationToServerKey) == true
            {return}
        }
        
        NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: kRemoteNotificationTokenKey)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidReportPushNotificationToServerKey)
        FCModel.sharedInstance.foodCollectorWebServer.reportDeviceTokenForPushWithDeviceNewToken(newToken)
    }
    
    //this is trrigerd when we have a token but could not post it to the server
    func resendPushNotificationToken() {
        if let token = oldToken {
            
            if !NSUserDefaults.standardUserDefaults().boolForKey(kDidReportPushNotificationToServerKey) && self.registeredForNotifications{
                FCModel.sharedInstance.foodCollectorWebServer.reportDeviceTokenForPushWithDeviceNewToken(token)
            }
        }
    }
    
    /// show action called by the show button on a notification view while the
    ///  app in background mode. app launches UI
    
    func pushShowActionForNotification(notification:[NSObject: AnyObject]) {
        
    }
    
    /// cancel action called by the show button on a notification view while the
    ///  app in background mode. app stays in backround
    
    func pushCancelActionForNotification(publication:[NSObject : AnyObject]) {
        
    }
    
    
    
    
    //MARK - Location Local Notifications
    
    func didRecieveLocalNotification(notification: UILocalNotification) {
        
        let userInfo = notification.userInfo
        if userInfo != nil {
            //handle the notification on FCContainerController

            NSNotificationCenter.defaultCenter().postNotificationName(kDidArriveOnSpotNotification, object: self, userInfo: userInfo)
        }
    }
    
    
    
    /// registers a location notification for all current Publications.
    /// this method is invoked by DidRecieveNewData Notification after fetching
    func registerForLocationNotifications(notification: NSNotification) {
        print("register for local notification")
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        self.registeredLocationNotification.removeAll(keepCapacity: false)
        for publication in FCModel.sharedInstance.publications {
            self.registerLocalNotification(publication)
        }
    }
    
    func registerLocalNotification(publication: Publication) {
        //check if we handeled
        let userInfo = [kPublicationUniqueIdKey : publication.uniqueId!.integerValue , kPublicationVersionKey : publication.version!.integerValue]
        let localNotification = UILocalNotification()
        localNotification.userInfo = userInfo
        localNotification.alertBody = String.localizedStringWithFormat(NSLocalizedString("You have arrived to: %@", comment: "location notification body: You have arrived to..."), publication.title!)
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.regionTriggersOnce = true
        localNotification.region = CLCircularRegion(center: publication.coordinate, radius: CLLocationDistance(kRegionRadiusForLocationNotification), identifier: publication.title!)
        localNotification.region!.notifyOnEntry = true
        localNotification.region!.notifyOnExit = false
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        self.registeredLocationNotification.append((localNotification, publication))
    }
    
    ///
    /// unregisters a location notification for a Publication.
    
    func removeLocationNotification(publication: Publication) {
        
        for (index, (notification , registeredPublication)) in self.registeredLocationNotification.enumerate() {
            if registeredPublication.uniqueId == publication.uniqueId &&
                registeredPublication.version == publication.version {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    self.registeredLocationNotification.removeAtIndex(index)
                    print("UNregister for local notification: \(registeredPublication.title)")
                    break
            }
        }
    }
    
    //MARK - Remote Notifications
    
    func didRecieveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
        if let notificationType = userInfo[kRemoteNotificationType] as? String {

            let data = userInfo[kRemoteNotificationDataKey] as? [String : AnyObject] ?? ["" : ""]
            let publicationIdentifier = self.identifierForInfo(data!)
            print("Notifications Handler data recieved:\n\(data) ")
            
            switch notificationType {
                
            case kRemoteNotificationTypeNewPublication:
                
                //we download the new publication from the server and append it to publications Array in FCModel
                print("Notifications Handler kRemoteNotificationTypeNewPublication ")
                self.handleNewPublicationFromPushNotification(publicationIdentifier)
            
            case kRemoteNotificationTypeDeletedPublication:
                
                print("Notifications Handler kRemoteNotificationTypeDeletedPublication ")
                self.handleDeletePublicationFromPushNotification(publicationIdentifier)
                
            case kRemoteNotificationTypePublicationReport:
                
                print("Notifications Handler kRemoteNotificationTypePublicationReport ")
                self.handlePublicationReportFromPushNotification(data!)
                
            case kRemoteNotificationTypeUserRegisteredForPublication:
                
                print("Notifications Handler kRemoteNotificationTypeUserRegisteredForPublication ")
                self.handleRegistrationFromPushNotification(data!)
                
            case kRemoteNotificationTypeGroupMembers:
                //This is called when members were added or removed from a group that the user is a member in
                self.handleGroupMembersChangedFromPushNotification(data!)
            default:
                break
            }
        }
    }
    
    func handleNewPublicationFromPushNotification(publicationIdentifier: PublicationIdentifier) {
        
        //fetch the new publication from the server
        //within the fetch we check whether it's a new publication or an update for an existing publication
      
            FCModel.sharedInstance.foodCollectorWebServer.fetchPublicationWithIdentifier(publicationIdentifier, completion: { (publication: Publication?) -> Void in
                    
                    //handle the new publication
                if let recivedPublication = publication {
                   
                    self.incrementNotificationsBadgeNumberIfNeededForType(kRemoteNotificationTypeNewPublication, publication: recivedPublication)
                    self.postUpdateNotificationCounterNotification()
                }
                
            })
    }
    
    func handleDeletePublicationFromPushNotification(publicationIdentifier: PublicationIdentifier){
        
        let publicationId = publicationIdentifier.uniqueId
        let predicate = NSPredicate(format: "uniqueId = %@", NSNumber(integer: publicationId))
        let results = (FCModel.sharedInstance.publications as NSArray).filteredArrayUsingPredicate(predicate) as! [Publication]
        if results.count > 0 {
            let toDelete = results.last!
            self.incrementNotificationsBadgeNumberIfNeededForType(kRemoteNotificationTypeDeletedPublication, publication: toDelete)
            FCModel.sharedInstance.deletePublication(toDelete, deleteFromServer: false)
            self.makeActivityLogForType(ActivityLog.LogType.DeletePublication, publication: toDelete)
        }
    }
    
    func handlePublicationReportFromPushNotification (data: [String : AnyObject]) {
        
        let id = data["publication_id"] as? Int ?? 0
        let predicate = NSPredicate(format: "uniqueId = %@", NSNumber(integer: id))
        if id > 0 {
            let results = (FCModel.sharedInstance.publications as NSArray).filteredArrayUsingPredicate(predicate) as! [Publication]
            if results.count > 0 {
                
                let publication = results.last!
                self.incrementNotificationsBadgeNumberIfNeededForType(kRemoteNotificationTypePublicationReport, publication: publication)
                let moc = FCModel.dataController.managedObjectContext
                FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, context: moc, completion: { (success) -> Void in })
            }
        }
    }
    
    func handleRegistrationFromPushNotification(data: [String : AnyObject]) {
        

        let id = data["id"] as? Int ?? 0
        let predicate = NSPredicate(format: "uniqueId = %@", NSNumber(integer: id))
        if id > 0 {
            let results = (FCModel.sharedInstance.publications as NSArray).filteredArrayUsingPredicate(predicate) as! [Publication]
            if results.count > 0 {
            
                let publication = results.last!
                self.incrementNotificationsBadgeNumberIfNeededForType(kRemoteNotificationTypeUserRegisteredForPublication, publication: publication)
                let moc = FCModel.dataController.managedObjectContext
                let fetcher = CDPublicationRegistrationFetcher(publication: publication, context: moc)
                fetcher.fetchRegistrationsForPublication(true)
                self.makeActivityLogForType(ActivityLog.LogType.Registration, publication: publication)
            }
        }
    }
    
    func handleGroupMembersChangedFromPushNotification(data: [String : AnyObject]) {
    
        //we increment the counter and create an ActivityLog only if the group was deleted
        let id = data["id"] as? Int
        guard let groupId = id else {return}
        FCModel.sharedInstance.foodCollectorWebServer.fetchMembersForGroup(groupId) { (success) -> Void in }
    }
    
    func makeActivityLogForType(type: ActivityLog.LogType, publication: Publication) {
        
        let moc = FCModel.dataController.managedObjectContext
        ActivityLog.activityLog(publication, group: nil ,type: type.rawValue, context: moc)
        
    }

    func postUpdateNotificationCounterNotification() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
          NSNotificationCenter.defaultCenter().postNotificationName(kUpdateNotificationsCounterNotification, object: nil)
        }
    }
    
    func identifierForInfo(data: [ NSObject: AnyObject?]) -> PublicationIdentifier {
        let uniqueId = data[kPublicationUniqueIdKey] as? Int ?? 0
        let version = data[kPublicationVersionKey] as? Int ?? 0
        let publicationIdentifier = PublicationIdentifier(uniqueId: uniqueId, version: version)
        return publicationIdentifier
    }
    
    func dateWithInfo(data: [NSObject: AnyObject?]) -> NSDate {
        let timeDouble = data[kRemoteNotificationPublicationReportDateKey] as? Double ?? NSDate().timeIntervalSince1970
        let date = NSDate(timeIntervalSince1970: timeDouble)
        return date
    }
    
    func saveNotificationBadgeCounter() {
        NSUserDefaults.standardUserDefaults().setInteger(notificationsBadgeCounter, forKey: kNotificationBadgeNumberKey)
    }
    
    func incrementNotificationsBadgeNumberIfNeededForType(type: String , publication: Publication?) {
    
        if !User.sharedInstance.settings.shouldPresentNotifications {return}
        guard let publication = publication else {return}
        let distanceFromUser = Int(publication.distanceFromUserLocation)
        let notificationsRadiusInMeters = User.sharedInstance.settings.notificationsRadius * 1000
        if  distanceFromUser >= notificationsRadiusInMeters {return}
    
        switch type {
        
        case kRemoteNotificationTypeNewPublication:
        
            
            self.notificationsBadgeCounter++
            
            
        case kRemoteNotificationTypeDeletedPublication,
             kRemoteNotificationTypePublicationReport,
             kRemoteNotificationTypeUserRegisteredForPublication:
            
            if publication.didRegisterForCurrentPublication?.boolValue == true { self.notificationsBadgeCounter++ }
            
        default:
            return
        }
    }
}


// MARK - Setup

extension FCUserNotificationHandler {
    func setup(){
        
        //we might not need this since we only register location notifications when a user
        //registers to come pick up a pubication
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "registerForLocationNotifications:", name: kRecievedNewDataNotification, object: nil)
        
        let showAction = UIMutableUserNotificationAction()
        showAction.identifier = "SHOW_IDENTIFIER"
        // Localized string displayed in the action button
        showAction.title = NSLocalizedString("Show Event", comment:"Alert show event button title")
        // If you need to show UI, choose foreground
        showAction.activationMode = UIUserNotificationActivationMode.Foreground
        // Destructive actions display in red
        showAction.destructive = false
        // Set whether the action requires the user to authenticate
        showAction.authenticationRequired = false
        
        let cancelAction = UIMutableUserNotificationAction()
        cancelAction.identifier = "DISSMISS_IDENTIFIER"
        // Localized string displayed in the action button
        cancelAction.title = kCancelButtonTitle
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
        
        
        let categoriesSet = Set(arrayLiteral: arrivedToPublicationCategory)// arrivedToPublicationCategory) as Set<NSObject>
        let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound];
        
        let settings = UIUserNotificationSettings(forTypes: types, categories: categoriesSet)

    
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
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


