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

    enum LogType: Int {case NewPublication = 1,EditedPublication = 2, DeletePublication = 3, Report = 4, Registration = 5, DeleteGroup = 6, NewGroup = 7}

    class func activityLog(publication: Publication?, group: Group? ,type: Int, context: NSManagedObjectContext) {
        
        
        context.performBlockAndWait { () -> Void in
            
            let newLog = NSEntityDescription.insertNewObjectForEntityForName("ActivityLog", inManagedObjectContext: context) as? ActivityLog
            newLog?.type = type
            newLog?.title = ActivityLog.titleForType(type, publication: publication, group: group)
            newLog?.date = NSDate()
            
            do {
                try context.save()
            } catch {
                print("error creating activity log \(error) ")
            }
        }
    }

    class func titleForType(type: Int, publication: Publication? , group: Group?) -> String {
        
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
            
        case .DeleteGroup:
            title = NSLocalizedString("Group was deleted: ", comment:"fetched data notification text: a group was eddited")
       
        case .NewGroup:
            title = NSLocalizedString("Group Added: ", comment:"fetched data notification text: a group was created")

        }
        
        var additionalTitle = ""
        
        if logType == .DeleteGroup || logType == .NewGroup {
            
            additionalTitle = group?.name ?? ""
            
        } else {
            
            additionalTitle = publication?.title ?? ""
            
        }

        return title + additionalTitle
    }
    
    func toString() -> String {
        return String("title: \(title)\ntype: \(type)\n")
    }
}
