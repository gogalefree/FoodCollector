//
//  ActivityLog.swift
//  FoodCollector
//
//  Created by Guy Freedman on 03/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData


class ActivityLog: NSManagedObject {

    enum LogType: Int {case NewPublication = 1,EditedPublication = 2, DeletePublication = 3, Report = 4, Registration = 5, newGroup = 6, newGroupMember = 7, deletedGroupMember = 8}

    class func activityLog(publication: Publication? ,type: Int, context: NSManagedObjectContext) {
        
        
        context.performBlockAndWait { () -> Void in
            
            let newLog = NSEntityDescription.insertNewObjectForEntityForName("ActivityLog", inManagedObjectContext: context) as? ActivityLog
            newLog?.type = type
            newLog?.title = ActivityLog.titleForType(type, publication: publication)
            newLog?.date = NSDate()
            
            do {
                try context.save()
            } catch {
                print("error creating activity log \(error) " + __FUNCTION__)
            }
        }
    }

    class func titleForType(type: Int, publication: Publication?) -> String {
        
        if type < 1 || type > 7 {return ""}
        
        let logType = LogType(rawValue: type)!
        
        var title = ""
        
        switch logType {
            
        case .NewPublication:
            title = kNewEventMessageTitle
            
        case .EditedPublication:
            title =  NSLocalizedString("Event Updated: ", comment:"Title for a notification")
            
        case .DeletePublication:
            title =  NSLocalizedString("Event Ended Near You: ", comment:"Title for a notification")
            
        case .Report:
            title = NSLocalizedString("New report for: ", comment:"Title for a notification")

        case .Registration:
            title = NSLocalizedString("User’s Coming To Pickup: ", comment:"fetched data notification text: Another user is en route to pickup:")
            
        case .newGroup:
            title = NSLocalizedString("You've benn added to a new group: ", comment:"fetched data notification text: current user was added to a new group")
         
            
        case .newGroupMember:
            title = NSLocalizedString("New group member in: ", comment:"fetched data notification text: Another user was added to a group")
            
        case .deletedGroupMember:
            title = NSLocalizedString("User was removed from a group: ", comment:"fetched data notification text: A user was removed from a group")
        }
        let publicationTitle = publication?.title ?? ""
        return title + publicationTitle
    }
    
    func toString() -> String {
        return String("title: \(title)\ntype: \(type)\n")
    }
}
