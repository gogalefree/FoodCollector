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
let kRemoteNotificationPublicationReportMessageKey = "report_message"
let kRemoteNotificationPublicationReportDateKey = "date"
let kRemoteNotificationTypeUserRegisteredForPublication = "registeration_for_publication"
let kRemoteNotificationRegistrationMessageForPublicationKey = "registration_message"
let kRemoteNotificationDataKey = "data"
let kRegionRadiusForLocationNotification = 5

let kDidArriveOnSpotNotification = "didArriveOnSpot"

class FCUserNotificationHandler : NSObject {
    
    
    var registeredForNotifications: Bool = {
        return UIApplication.sharedApplication().currentUserNotificationSettings().types != nil
        }()
    
    var oldToken: String? = {
        return NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey) as? NSString
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
            if currentToken == newToken {return}
        }
        
        FCModel.sharedInstance.foodCollectorWebServer.reportDeviceTokenForPushWithDeviceNewToken(newToken)
        
        NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: kRemoteNotificationTokenKey)
    }
    
    //this is trrigerd when we have a token but could not post it to the server
    func resendPushNotificationToken() {
        if let token = oldToken {
            
            if NSUserDefaults.standardUserDefaults().boolForKey(kDidFailToRegisterPushNotificationKey) == true {
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
        println("register for local notification")
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        self.registeredLocationNotification.removeAll(keepCapacity: false)
        for publication in FCModel.sharedInstance.publications {
            self.registerLocalNotification(publication)
        }
    }
    
    func registerLocalNotification(publication: FCPublication) {
        //check if we handeled
        println("registered \(publication.title)")
        let userInfo = [kPublicationUniqueIdKey : publication.uniqueId , kPublicationVersionKey : publication.version]
        let localNotification = UILocalNotification()
        localNotification.userInfo = userInfo
        localNotification.alertBody =
            String.localizedStringWithFormat("הגעת ל: \(publication.title)",
            "location notification body")
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.regionTriggersOnce = true
        localNotification.region = CLCircularRegion(center: publication.coordinate, radius: CLLocationDistance(kRegionRadiusForLocationNotification), identifier: publication.title)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        self.registeredLocationNotification.append((localNotification, publication))
    }
    
    ///
    /// unregisters a location notification for a Publication.
    
    func removeLocationNotification(publication: FCPublication) {
        
        for (index, (notification , registeredPublication)) in enumerate(self.registeredLocationNotification) {
            if registeredPublication.uniqueId == publication.uniqueId &&
                registeredPublication.version == publication.version {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    self.registeredLocationNotification.removeAtIndex(index)
                    println("UNregister for local notification: \(registeredPublication.title)")
                    break
            }
        }
    }
    
    //MARK - Remote Notifications
    
    func didRecieveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
        if let notificationType = userInfo[kRemoteNotificationType] as? String {
            
            let data = userInfo[kRemoteNotificationDataKey]! as [String : AnyObject]
            
            switch notificationType {
                
            case kRemoteNotificationTypeNewPublication:
                
                let newPublication = FCPublication.publicationWithParams(data)
                if !self.didHandleNewPublicationNotification(newPublication) {
                    self.recievedPublications.removeAll(keepCapacity: true)
                    self.recievedPublications.append(newPublication)
                    FCModel.sharedInstance.addPublication(newPublication)
                }
                
                
                
            case kRemoteNotificationTypeDeletedPublication:
                
                let publicationIdentifier = self.identifierForInfo(data)
                if !self.didHandlePublicationToDelete(publicationIdentifier){
                    self.recivedtoDelete.removeAll(keepCapacity: true)
                    self.recivedtoDelete.append(publicationIdentifier)
                    FCModel.sharedInstance.deletePublication(publicationIdentifier)
                }
                
            case kRemoteNotificationTypePublicationReport:
                
                let publicationIdentifier = self.identifierForInfo(data)
                let reportDate = self.dateWithInfo(data)
                let reportMessage = data[kRemoteNotificationPublicationReportMessageKey]! as Int
                let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage(rawValue: reportMessage)!, date: reportDate)
                
                if !self.didHandlePublicationReport(report, publicationIdentifier: publicationIdentifier) {
                    self.recivedReports.removeAll(keepCapacity: true)
                    self.recivedReports.append((publicationIdentifier, report))
                    FCModel.sharedInstance.addPublicationReport(report, identifier: publicationIdentifier)
                }
                
                
            case kRemoteNotificationTypeUserRegisteredForPublication:
                
                let publicationIdentifier = identifierForInfo(data)
                let registrationDate = dateWithInfo(data)
                
                let registrationMessage = data[kRemoteNotificationRegistrationMessageForPublicationKey]! as Int
                
                let registration = FCRegistrationForPublication(identifier: publicationIdentifier, dateOfOrder: registrationDate, registrationMessage: FCRegistrationForPublication.RegistrationMessage(rawValue: registrationMessage)!)
                
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
                registration.identifier.version == publicationIdentifier.version &&
                registration.dateOfOrder == publicationRegistration.dateOfOrder &&
                registration.registrationMessage == publicationRegistration.registrationMessage {
                    exist = true
            }
        }
        return exist
    }
    
    func identifierForInfo(data: [ NSObject: AnyObject?]) -> PublicationIdentifier {
        let uniqueId = data[kPublicationUniqueIdKey]! as Int
        let version = data[kPublicationVersionKey]! as Int
        let publicationIdentifier = PublicationIdentifier(uniqueId: uniqueId, version: version)
        return publicationIdentifier
    }
    
    func dateWithInfo(data: [NSObject: AnyObject?]) -> NSDate {
        let timeInt = data[kRemoteNotificationPublicationReportDateKey]! as Int
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(timeInt))
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


