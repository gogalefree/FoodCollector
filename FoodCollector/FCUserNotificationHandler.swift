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
    
    func didRecieveLocalNotification(notification: UILocalNotification) {
        
    }
    
    func didRecieveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
        if let notificationType = userInfo[kRemoteNotificationType] as? String {
            
            switch notificationType {
                
            case kRemoteNotificationTypeNewPublication:
                
                let newPublication = FCPublication.publicationWithParams(userInfo[kRemoteNotificationDataKey] as [String : String])
                if !self.didHandleNewPublicationNotification(newPublication) {
                    self.recievedPublications.removeAll(keepCapacity: true)
                    self.recievedPublications.append(newPublication)
                    FCModel.sharedInstance.addPublication(newPublication)
                }
                
                
                
            case kRemoteNotificationTypeDeletedPublication:
                
                let data = userInfo[kRemoteNotificationDataKey]! as [String : String]
                let uniqueId = data[kPublicationUniqueIdKey]!.toInt()!
                let version = data[kPublicationVersionKey]!.toInt()!
                let publicationIdentifier = PublicationIdentifier(uniqueId: uniqueId, version: version)
                if !self.didHandlePublicationToDelete(publicationIdentifier){
                    self.recivedtoDelete.removeAll(keepCapacity: true)
                    self.recivedtoDelete.append(publicationIdentifier)
                    FCModel.sharedInstance.deletePublication(publicationIdentifier)
                }
                
            case kRemoteNotificationTypePublicationReport:
                
                let data = userInfo[kRemoteNotificationDataKey] as [String : AnyObject]
                let publicationIdentifier = self.identifierForInfo(data)
                let reportDate = self.dateWithInfo(data)
                let reportMessage = (data[kRemoteNotificationPublicationReportMessageKey]as String!).toInt()!
                let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage(rawValue: reportMessage)!, date: reportDate)
                
                if !self.didHandlePublicationReport(report, publicationIdentifier: publicationIdentifier) {
                    self.recivedReports.removeAll(keepCapacity: true)
                    self.recivedReports.append((publicationIdentifier, report))
                    FCModel.sharedInstance.addPublicationReport(report, identifier: publicationIdentifier)
                }
                
                
            case kRemoteNotificationTypeUserRegisteredForPublication:
                
                let data = userInfo[kRemoteNotificationDataKey] as [String : AnyObject]
                let publicationIdentifier = self.identifierForInfo(data)
                let registrationDate = self.dateWithInfo(data)
                
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
    func removeLocationNotification(publication: FCPublication) {
        
        for (index, (notification , registeredPublication)) in enumerate(self.registeredLocationNotification) {
            if registeredPublication.uniqueId == publication.uniqueId &&
                registeredPublication.version == publication.version {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    self.registeredLocationNotification.removeAtIndex(index)
                    break
            }
        }
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
        let localNotification = UILocalNotification()
        localNotification.alertBody = String.localizedStringWithFormat("You've arrived", "location notification body")
        localNotification.regionTriggersOnce = false
        localNotification.region = CLCircularRegion(center: publication.coordinate, radius: CLLocationDistance(20), identifier: publication.title)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        self.registeredLocationNotification.append((localNotification, publication))
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
    
    func identifierForInfo(data: [String: AnyObject?]) -> PublicationIdentifier {
        let uniqueId = (data[kPublicationUniqueIdKey] as String!).toInt()!
        let version = (data[kPublicationVersionKey] as String!).toInt()!
        let publicationIdentifier = PublicationIdentifier(uniqueId: uniqueId, version: version)
        return publicationIdentifier
    }
    
    func dateWithInfo(data: [String: AnyObject?]) -> NSDate {
        let timeInt = data[kRemoteNotificationPublicationReportDateKey]! as Int
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(timeInt))
        return date
    }
}


// MARK - Setup

extension FCUserNotificationHandler {
    func setup(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "registerForLocationNotifications:", name: kRecievedNewDataNotification, object: nil)
        
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


