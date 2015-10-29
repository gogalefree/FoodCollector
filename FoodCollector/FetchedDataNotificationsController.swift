//
//  FetchedDataNotificationsController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

let kDidPrepareNotificationsFromWebFetchNotification = "kDidPrepareNotificationsFromWebFetchNotification"

class FetchedDataNotificationsController: NSObject {

    let numberOfNotificationsToPresent = 5
    var notifications = [FetchedDataNotification]()
    var notificationViews = [FetchedDataNotificationView]()
    
    func prepareNotificationsFromWebFetch() {
        
        self.notifications.removeAll()
        self.notificationViews.removeAll()
        
        let deleted = FCModel.sharedInstance.publicationsToDelete
        let newPublications = FCModel.sharedInstance.newPublications
        let reports = FCModel.sharedInstance.fetchedPublications.filter {(publication: FCPublication) in publication.didRecieveNewReport}
        let registrations = FCModel.sharedInstance.fetchedPublications.filter {(publication: FCPublication) in publication.didRecieveNewRegistration}
        
        for publication in registrations {
            notifications.insert(FetchedDataNotification(publication, type: .Registration), atIndex: 0)
        }

        for publication in reports {
            notifications.insert(FetchedDataNotification(publication, type: .Report), atIndex: 0)
        }
        
        for publication in newPublications {
            notifications.insert(FetchedDataNotification(publication, type: .NewPublication), atIndex: 0)
        }
        
        for publication in deleted {
            notifications.insert(FetchedDataNotification(publication, type: .DeletePublication), atIndex: 0)
        }
        
        print(__FUNCTION__)
        print("registration notifications count: \(registrations.count)")
        print("reports notifications count: \(reports.count)")
        print("new publi notifications count: \(newPublications.count)")
        print("deleted publi notifications count: \(deleted.count)")

        if notifications.count > 5 {
            notifications = Array(notifications.suffix(numberOfNotificationsToPresent))
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in

            for notification in self.notifications {
                let view = FetchedDataNotificationView.loadFromNibNamed("FetchedDataNotificationView", bundle: nil) as! FetchedDataNotificationView
                view.notification = notification
                self.notificationViews.append(view)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(kDidPrepareNotificationsFromWebFetchNotification, object: nil)
        }
    }
}

extension FetchedDataNotificationsController {
    //SingleTone Shared Instance
    class var shared : FetchedDataNotificationsController {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FetchedDataNotificationsController? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FetchedDataNotificationsController()
        }
        return Static.instance!
    }
}

