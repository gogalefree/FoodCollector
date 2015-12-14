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
let kRemoteNotificationDataKey = "data"
let kShouldShowNewPublicationFromPushNotification = "kShouldShowNewPublicationFromPushNotification"
let kRegionRadiusForLocationNotification = 20

let kDidArriveOnSpotNotification = "didArriveOnSpot"

class FCUserNotificationHandler : NSObject {
    
    
    var registeredForNotifications: Bool = {
        return UIApplication.sharedApplication().currentUserNotificationSettings()!.types != []
        }()
    
    var oldToken: String? = {
        print("Push TOKEN: \(NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey))")
        return NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey) as? String
        }()
    
    var registeredLocationNotification = [(UILocalNotification, FCPublication)]()
    var recievedPublications = [FCPublication]()
    var recivedtoDelete = [PublicationIdentifier]()
    var recivedReports = [(PublicationIdentifier, FCOnSpotPublicationReport)]()
    var recievedRegistrations = [FCRegistrationForPublication]()
    var recivedLocationNotification = [[NSObject : AnyObject]]()
    
    /// this method receives the new token and calls the server’s
    /// reportNewToken:oldToken:
    
    func registerForPushNotificationWithToken(newToken:String) {
        
        if let currentToken = self.oldToken {
            if currentToken == newToken && NSUserDefaults.standardUserDefaults().boolForKey(kDidReportPushNotificationToServerKey) == true
            {return}
        }
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidReportPushNotificationToServerKey)
        FCModel.sharedInstance.foodCollectorWebServer.reportDeviceTokenForPushWithDeviceNewToken(newToken)
        NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: kRemoteNotificationTokenKey)
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
            //handle the notification on FCMainTabBarController
            self.recivedLocationNotification.append(userInfo!)
            NSNotificationCenter.defaultCenter().postNotificationName(kDidArriveOnSpotNotification, object: self, userInfo: userInfo)
        }
    }
    
    /// called when a user arrives to a publication spot.
    /// called by the app as a result of user location notification
    func didArriveToPublicationSpot(publication:FCPublication) {
        
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
    
    func registerLocalNotification(publication: FCPublication) {
        //check if we handeled
        let userInfo = [kPublicationUniqueIdKey : publication.uniqueId , kPublicationVersionKey : publication.version]
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
    
    func removeLocationNotification(publication: FCPublication) {
        
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

            let data = userInfo[kRemoteNotificationDataKey]! as! [String : AnyObject]
            let publicationIdentifier = self.identifierForInfo(data)
            
            switch notificationType {
                
            case kRemoteNotificationTypeNewPublication:
                
                self.handleNewPublicationFromPushNotification(publicationIdentifier)
            
            case kRemoteNotificationTypeDeletedPublication:
                
                if !self.didHandlePublicationToDelete(publicationIdentifier){
                    self.recivedtoDelete.removeAll(keepCapacity: true)
                    self.recivedtoDelete.append(publicationIdentifier)
                    FCModel.sharedInstance.prepareToDeletePublication(publicationIdentifier)
                }
                
            case kRemoteNotificationTypePublicationReport:
                
                let id = data["publication_id"] as? Int ?? 0
                let pulicationVersion = data["publication_version"] as? Int ?? 0
                let publicationIdentifier = PublicationIdentifier(uniqueId: id , version: pulicationVersion)
                let reportDate = self.dateWithInfo(data)
                let reportMessage = data[kRemoteNotificationPublicationReportMessageKey] as? Int ?? 0
                let contactInfo = ""
                
                let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage(rawValue: reportMessage)!, date: reportDate , reportContactInfo: contactInfo, reportPublicationId: publicationIdentifier.uniqueId, reportPublicationVersion: publicationIdentifier.version,reportId: 0 , reportCollectorName: "")
                
                if !self.didHandlePublicationReport(report, publicationIdentifier: publicationIdentifier) {
                    self.recivedReports.removeAll(keepCapacity: true)
                    self.recivedReports.append((publicationIdentifier, report))
                    FCModel.sharedInstance.addPublicationReport(report, identifier: publicationIdentifier)
                }
                
                
            case kRemoteNotificationTypeUserRegisteredForPublication:
                
                let registrationDate = self.dateWithInfo(data)
                let id = data["id"] as? Int ?? 0
                let pulicationVersion = data["version"] as? Int ?? 0
                let publicationIdentifier = PublicationIdentifier(uniqueId: id , version: pulicationVersion)
                let registration = FCRegistrationForPublication(identifier: publicationIdentifier, dateOfOrder: registrationDate, contactInfo: "Unavilable", collectorName: "No Name", uniqueId: 0)
                
                if !self.didHandlePublicationRegistration(registration, publicationIdentifier: publicationIdentifier) {
                    self.recievedRegistrations.removeAll(keepCapacity: true)
                    self.recievedRegistrations.append(registration)
                    FCModel.sharedInstance.didRecievePublicationRegistration(registration)
                }
                
            default:
                break
            }
        }
    }
    
    func handleNewPublicationFromPushNotification(publicationIdentifier: PublicationIdentifier) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            //check if publication exists
            if FCModel.sharedInstance.publicationWithIdentifier(publicationIdentifier) == nil {
                
                //fetch the new publication from the server
                FCModel.sharedInstance.foodCollectorWebServer.fetchPublicationWithIdentifier(publicationIdentifier, completion: { (publication: FCPublication) -> Void in
                    
                    //handle the new publication
                    let recivedPublication = publication
                    if !self.didHandleNewPublicationNotification(recivedPublication) {
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey:kShouldShowNewPublicationFromPushNotification)
                        self.recievedPublications.removeAll(keepCapacity: true)
                        self.recievedPublications.append(recivedPublication)
                        FCModel.sharedInstance.addPublication(recivedPublication)
                    }
                })
            }
        })
    }
    
    func didHandleNewPublicationNotification(incomingPublication: FCPublication) -> Bool {
        
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
    
    func didHandlePublicationToDelete(publicationIdentifier: PublicationIdentifier) -> Bool {
        var exist = false
        for toDelete in self.recivedtoDelete {
            if publicationIdentifier.uniqueId == toDelete.uniqueId &&
                publicationIdentifier.version == toDelete.version{
                    exist = true
                    break
            }
        }
        return exist
    }
    
    func didHandlePublicationReport(report: FCOnSpotPublicationReport, publicationIdentifier: PublicationIdentifier) -> Bool {
        var exist = false
        for (identifier, currentReport) in self.recivedReports {
            if identifier.uniqueId == publicationIdentifier.uniqueId &&
                identifier.version == publicationIdentifier.version &&
                currentReport.date == report.date {
                    exist = true
                    break
            }
        }
        return exist
    }
    
    func didHandlePublicationRegistration(publicationRegistration: FCRegistrationForPublication, publicationIdentifier: PublicationIdentifier) -> Bool {
        var exist = false
        for registration in self.recievedRegistrations {
            if  registration.identifier.uniqueId == publicationIdentifier.uniqueId &&
                registration.identifier.version == publicationIdentifier.version   &&
                registration.dateOfOrder == publicationRegistration.dateOfOrder     {
                    exist = true
            }
        }
        return exist
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


