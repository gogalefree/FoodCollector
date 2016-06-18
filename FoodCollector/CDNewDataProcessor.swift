//
//  CDNewDataProcessor.swift
//  FoodCollector
//
//  Created by Guy Freedman on 28/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class CDNewDataProcessor: NSObject {

    class func processDataFromWebFetch(jsonArray: [[String: AnyObject]]){
    
        
        //Create a context on a private queue
        let localContext = FCModel.sharedInstance.dataController.createPrivateQueueContext()
         
        //Sort the dictionaries by code so they can be compared in parallel
        let publicationDictionaries = jsonArray.sort { lhs, rhs in
            let lhsResult = lhs[kPublicationUniqueIdKey] as? Int ?? 0
            let rhsResult = rhs[kPublicationUniqueIdKey] as? Int ?? 0
            return lhsResult < rhsResult
        }
        
        // To avoid a high memory footprint, process records in batches.
        let batchSize = 50
        let count = publicationDictionaries.count
        
        var numBatches = count / batchSize
        numBatches += count % batchSize > 0 ? 1 : 0
        
        for batchNumber in 0 ..< numBatches {
            
            let batchStart = batchNumber * batchSize
            let batchEnd = batchStart + min(batchSize, count - batchNumber * batchSize)
            let range = batchStart..<batchEnd
            
            let publicationsBatch = Array(publicationDictionaries[range])
            
            CDNewDataProcessor.updateAndAddPublicationsFromDictionaries(publicationsBatch, usingContext: localContext)
            
            do {
                
                try localContext.save()
            } catch {
                print("error saving local context: \(error)")
            }
            
            if batchNumber == (numBatches + 1) {
                FCModel.sharedInstance.processingData = false
                FCModel.sharedInstance.postReloadDataNotificationOnMainThread()
            }
        }
        
    }
    
    class func updateAndAddPublicationsFromDictionaries(results: [[String: AnyObject]], usingContext localContext: NSManagedObjectContext) {
        
        for dict in results {
            print("publication: \(dict)", separator: "===", terminator: "\n========end publication json============")
            print("\n")
            
        }
        
        let arrivedIds: [NSNumber] = results.map { dictionary in
            return NSNumber(integer: dictionary[kPublicationUniqueIdKey] as! Int)
        }
        
        //delete old
        let toDeletePredicate = NSPredicate(format: "NOT (uniqueId in %@)", argumentArray: [arrivedIds])
        let deleteFetchRequest   = NSFetchRequest(entityName: kPublicationEntity)
        deleteFetchRequest.predicate = toDeletePredicate
        
        localContext.performBlockAndWait { () -> Void in
            
            defer {
                
                do {
                    try localContext.save()

                } catch {
                    print("error deleting old publications \(error)")
                }
            }
            
            let publicationsToDelete = try! localContext.executeFetchRequest(deleteFetchRequest) as? [Publication]
            if let toDelete = publicationsToDelete {
                for publication in toDelete {
                    
                    //keep user created publications
                    if publication.isUserCreatedPublication == true {continue}
                    
                    //make delete notification object
                    let delete = ActivityLog.LogType.DeletePublication.rawValue
                    ActivityLog.activityLog(publication, group: nil, type: delete, context: localContext)
                    localContext.deleteObject(publication)
                }
            }
        }
        
        
        //update existing
        let existingPredicate = NSPredicate(format: "uniqueId in %@", argumentArray: [arrivedIds])
        let existingFetchRequest   = NSFetchRequest(entityName: kPublicationEntity)
        existingFetchRequest.predicate = existingPredicate
        
        localContext.performBlockAndWait { () -> Void in
            
            defer {
                
                do {
                    try localContext.save()
                    
                } catch {
                    print("error deleting old publications \(error)")
                }
            }
            
            let existingPublications =  try! localContext.executeFetchRequest(existingFetchRequest) as? [Publication]
            if let toUpdate = existingPublications {
                
                for publication in toUpdate {
                   
                    let dictionaries = results.filter {(dictionary) in
                        return dictionary[kPublicationUniqueIdKey] as? Int == publication.uniqueId?.integerValue
                    }
                    
                    guard let dictionary = dictionaries.first else {continue}
                    
                    print("dictionary to update \(dictionary)")
                    publication.updateFromParams(dictionary, context: localContext)
                }
            }
        }
        
        //create new
        for dict in results {
            
            defer {
                
                do {
                    try localContext.save()
                    
                } catch {
                    print("error deleting old publications \(error)")
                }
            }
            
            guard let unique = dict[kPublicationUniqueIdKey] as? Int else {continue}
            let id =  NSNumber(integer: unique)
            //fetch with id
            let existingPredicate = NSPredicate(format: "uniqueId = %@", id)
            let existingFetchRequest   = NSFetchRequest(entityName: kPublicationEntity)
            existingFetchRequest.predicate = existingPredicate
            
            localContext.performBlockAndWait({ () -> Void in
                
                let existingPublications =  try! localContext.executeFetchRequest(existingFetchRequest) as? [Publication]
                if let founds = existingPublications {
                    
                    if founds.count == 0 {
                        
                        //create the new one
                        let publication = NSEntityDescription.insertNewObjectForEntityForName(kPublicationEntity, inManagedObjectContext: localContext) as? Publication
                        if let newPublication = publication {
                            newPublication.updateFromParams(dict, context: localContext)
                            
                            //create notification object
                            let new = ActivityLog.LogType.NewPublication.rawValue
                            ActivityLog.activityLog(newPublication, group: nil, type: new, context: localContext)                            
                        }
                    }
                }
            })
        }
        //fetch Reports
        
        let request = NSFetchRequest(entityName: kPublicationEntity)
        
        var publications: [Publication]?
        
        localContext.performBlockAndWait { () -> Void in
            
            publications = try! localContext.executeFetchRequest(request) as? [Publication]
            guard let currentPublications = publications else {return}

            for publication in currentPublications {
                
                FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, context: localContext, completion: { (success) -> Void in})
            }
        }
        
        //fetchRegistration
        
        
            localContext.performBlockAndWait { () -> Void in
                
                
                if let currentPublications = publications {
                    
                    for (publication) in currentPublications {
                        
                        let registrationFetcher = CDPublicationRegistrationFetcher(publication: publication, context: localContext)
                        registrationFetcher.fetchRegistrationsForPublication(true)
                    }
                    
                    FCModel.sharedInstance.postReloadDataNotificationOnMainThread()
                    
                }
            }
        
        //fetch groups
        if User.sharedInstance.userIsLoggedIn {
           
            CDNewDataProcessor.fetchGroups(localContext)
            CDNewDataProcessor.fetchPublicationsForUser()
            
        } else {
           
            FCModel.sharedInstance.postReloadDataNotificationOnMainThread()
        }
        
        //indexInSpotlight
        let indexer = FDSpotlightIndexer()
        indexer.startIndexing()
    }
    
    class func fetchGroups(context: NSManagedObjectContext) {
        
        context.performBlockAndWait { () -> Void in
            
            defer {
                
                do {
                    try context.save()
                    FCModel.sharedInstance.processingData = false
                    FCModel.sharedInstance.postReloadDataNotificationOnMainThread()
                } catch {
                    print("error saving context afetr groups fetch \(error)")
                }
            }
        
            FCModel.sharedInstance.foodCollectorWebServer.fetchGroupsForUser(context)
        }
    }
    
    class func proccessPublicationForUser(arrayOfPublicationDicts: [[String: AnyObject]]) {
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        
        //create new if needed
        for dict in arrayOfPublicationDicts {
            
            
            guard let unique = dict[kPublicationUniqueIdKey] as? Int else {continue}
            let id =  NSNumber(integer: unique)
           
            //fetch with id
            let existingPredicate = NSPredicate(format: "uniqueId = %@", id)
            let existingFetchRequest   = NSFetchRequest(entityName: kPublicationEntity)
            existingFetchRequest.predicate = existingPredicate
            
            moc.performBlock({ () -> Void in
                
                do {
                    
                    let existingPublications =  try moc.executeFetchRequest(existingFetchRequest) as? [Publication]
                    if let founds = existingPublications {
                        
                        if founds.count == 0 {
                            
                            //create the new one
                            let publication = NSEntityDescription.insertNewObjectForEntityForName(kPublicationEntity, inManagedObjectContext: moc) as? Publication
                            if let newPublication = publication {
                                newPublication.updateFromParams(dict, context: moc)
                                
                                //create notification object
                                let new = ActivityLog.LogType.NewPublication.rawValue
                                ActivityLog.activityLog(newPublication, group: nil, type: new, context: moc)
                            }
                        }
                        
                        else if founds.count > 0 {
                            
                            if let publication = founds.first {
                                publication.updateFromParams(dict, context: moc)
                            }
                        }
                    }

        
                    
                }catch let error as NSError {
                    print("error creating new publication for user: " + error.description + " " + #function)
                }
            })
        }
        
        let arrivedIds: [NSNumber] = arrayOfPublicationDicts.map { dictionary in
            return NSNumber(integer: (dictionary[kPublicationUniqueIdKey] as? Int ?? 0))
        }
        
        //delete old
        let toDeletePredicate = NSPredicate(format: "NOT (uniqueId in %@)", argumentArray: [arrivedIds])
        let deleteFetchRequest   = NSFetchRequest(entityName: kPublicationEntity)
        deleteFetchRequest.predicate = toDeletePredicate
        
        moc.performBlock { 
            
            do {
             
                let allNotArrived = try moc.executeFetchRequest(deleteFetchRequest) as? [Publication]
                if let toDelete = allNotArrived {
                    
                    let userPublicationsToDelete = toDelete.filter { publication in
                    
                        return publication.audiance!.integerValue != 0
                    }
                    
                    for publication in userPublicationsToDelete {
                        
                        //keep user created publications
                        if publication.isUserCreatedPublication == true {continue}
                        
                        //make delete notification object
                        let delete = ActivityLog.LogType.DeletePublication.rawValue
                        ActivityLog.activityLog(publication, group: nil, type: delete, context: moc)
                        moc.deleteObject(publication)
                    }
                    
                    FCModel.sharedInstance.dataController.save()
                }
                
            } catch let error as NSError {
                print("error deleting old publication for user: " + error.description + " " + #function)

            }
        }
    }
    
    class func fetchGroupsAfterLogin() {
        FCModel.sharedInstance.processingData = true
        let localContext = FCModel.sharedInstance.dataController.createPrivateQueueContext()
        CDNewDataProcessor.fetchGroups(localContext)
    }
    
    class func fetchPublicationsForUser() {
        FCModel.sharedInstance.foodCollectorWebServer.publicationsForUser()
    }
}
