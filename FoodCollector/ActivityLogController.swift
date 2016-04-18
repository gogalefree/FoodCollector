//
//  FetchedDataNotificationsController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

let kDidPrepareNotificationsFromWebFetchNotification = "kDidPrepareNotificationsFromWebFetchNotification"

class ActivityLogController: NSObject {

    let numberOfNotificationsToPresent = 5
    var logs = [ActivityLog]()
    
    override init() {
        super.init()
        loadLogObjects()
    }
    
    func loadLogObjects() {
        
        let moc = FCModel.dataController.managedObjectContext
        moc.performBlock { () -> Void in
            
            let request = NSFetchRequest(entityName: "ActivityLog")
            
            do {
                
                let newLogs = try moc.executeFetchRequest(request) as? [ActivityLog]
                if let someLogs = newLogs {
                    self.logs = someLogs
                }
            } catch {
                print("error fetching logs \(error) " + #function)
            }
            
        }
    }
    
}

extension ActivityLogController {
    //SingleTone Shared Instance
    class var shared : ActivityLogController {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ActivityLogController? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ActivityLogController()
        }
        return Static.instance!
    }
}

