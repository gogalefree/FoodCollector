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
                newLog?.timeString = FCDateFunctions.timeStringForActivityLogCell(publication!.startingData!)
            }
            else {
                newLog?.objectId = group?.id
                newLog?.setLogImageDataForGroup(group!, context: context)
                newLog?.timeString = FCDateFunctions.timeStringForActivityLogCell(newLog!.date!)
            }
            
            
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
                
                context.performBlock({
                    self.logImage = publication.photoBinaryData
                    print("data: \(self.logImage?.length)")
                    do {
                        
                        try self.managedObjectContext?.save()
                    } catch {
                        print (error)
                    }
                    
                })
            })
        }
        
        else {self.logImage = publication.photoBinaryData }
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
    
    func toString() -> String {
        return String("title: \(title)\ntype: \(type)\n")
    }
}
