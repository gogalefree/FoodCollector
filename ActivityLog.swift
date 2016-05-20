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
    
    var timeStringFromCreation: String {
        return FCDateFunctions.timeStringForActivityLogCell(self.date!)
    }

    enum LogType: Int {case NewPublication = 1, DeletePublication = 2, Report = 3, Registration = 4,  NewGroup = 5}

    class func activityLog(publication: Publication?, group: Group? ,type: Int, context: NSManagedObjectContext) {
        
        
        context.performBlockAndWait { () -> Void in
            
            let newLog = NSEntityDescription.insertNewObjectForEntityForName("ActivityLog", inManagedObjectContext: context) as? ActivityLog
            newLog?.type = type
            newLog?.title = ActivityLog.titleForType(type, publication: publication, group: group)
            newLog?.subtitle = ActivityLog.subtitleForType(type, publication: publication, group: group)
            newLog?.date = NSDate()
            
            if publication != nil {
                newLog?.objectId = publication?.uniqueId
                newLog?.objectVerion = publication?.version
                newLog?.setLogImageDataForPublication(publication!, context: context)
                newLog?.date = publication?.startingData
                newLog?.timeString = FCDateFunctions.timeStringForActivityLogCell(publication!.startingData!)
            }
            else {
                newLog?.objectId = group?.id
                newLog?.setLogImageDataForGroup(group!, context: context)
                newLog?.date = group?.createdAt
                newLog?.timeString = FCDateFunctions.timeStringForActivityLogCell(group!.createdAt!)
            }
            
            FCUserNotificationHandler.sharedInstance.notificationsBadgeCounter += 1 
            
            do {
                try context.save()
            } catch {
                print("error creating activity log \(error) ")
            }
        }
    }

    class func titleForType(type: Int, publication: Publication? , group: Group?) -> String {
        
        if type < 1 || type > 5 {return ""}
        
        let logType = LogType(rawValue: type)!
        
        var title = ""
        
        switch logType {
            
        case .NewPublication:
            title = kNewEventMessageTitle
            
            
        case .DeletePublication:
            title =  NSLocalizedString("Event Ended Near You: ", comment:"Title for a notification")
            
        case .Report:
            title = NSLocalizedString("New report for: ", comment:"Title for a notification")

        case .Registration:
            title = NSLocalizedString("User Joined To Pickup: ", comment:"fetched data notification text: Another user is en route to pickup:")
            
         
        case .NewGroup:
            title = NSLocalizedString("You've been added to group: ", comment:"fetched data notification text: a group was created")

        }
        
        return title
    }
    
    class func subtitleForType(type: Int, publication: Publication? , group: Group?) -> String {
        
        if type < 1 || type > 5 {return ""}
        
        let logType = LogType(rawValue: type)!
        
        var subtitle = ""
        
        switch logType {
            
        case .NewPublication , .DeletePublication, .Report, .Registration:
            subtitle = publication?.title ?? ""
            
            
        case .NewGroup:
            subtitle = group?.name ?? ""
        }
        
        return subtitle
    }

    func setLogImageDataForPublication(publication: Publication, context: NSManagedObjectContext) {
        if publication.photoBinaryData == nil {
            
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(publication, completion: { (image) in
                
                print(publication.title)
                guard let photo = image else {return}
                print(publication.title)
                
                context.performBlock({
                    self.logImage = UIImageJPEGRepresentation(photo, 1)
                    print("data: \(self.logImage?.length)")
                    do {
                        
                        try self.managedObjectContext?.save()
                    } catch {
                        print (error)
                    }
                    
                })
            })
        }
        
        else {
            self.logImage = publication.photoBinaryData
        }
    }
    
    func setLogImageDataForGroup(group: Group, context: NSManagedObjectContext) {
        
        let fetcher = FCUserPhotoFetcher()
        fetcher.userPhotoForGroup(group) { (image) in
            if let photo = image {
                
                let imageData = UIImageJPEGRepresentation(photo, 1)
                context.performBlock({
                    self.logImage = imageData
                    print("data: \(self.logImage?.length)")
                    do {
                        
                        try self.managedObjectContext?.save()
                    } catch {
                        print(error)
                    }
                })
            }
        }
    }
    
    class func deleteLogsAfetrLogout() {

        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: kActivityLogEntity)
        request.predicate = NSPredicate(format: "type  > %@", NSNumber(integer: 2))
        do {
            let results = try moc.executeFetchRequest(request) as? [ActivityLog]
            guard let logsToDelete = results else {return}
            for log in logsToDelete {
                moc.performBlock({ 
                    moc.deleteObject(log)
                })
            }
            
        } catch let error as NSError{
            print(error.description + " " + #function)
        }
    }
    
    func toString() -> String {
        return String("title: \(title)\ntype: \(type)\n")
    }
}
