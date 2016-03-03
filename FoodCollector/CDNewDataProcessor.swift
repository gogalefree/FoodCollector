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
        let localContext = FCModel.dataController.createPrivateQueueContext()
        
        
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
        
        for var batchNumber = 0; batchNumber < numBatches; batchNumber++ {
            
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
        }
    }
    
    class func updateAndAddPublicationsFromDictionaries(results: [[String: AnyObject]], usingContext localContext: NSManagedObjectContext) {
        
        for dict in results {
            print("publication: \(dict)", separator: "===end publication===", terminator: "end publication json")
            print("\n")
            
        }
        
        let arrivedIds: [NSNumber] = results.map { dictionary in
            return NSNumber(integer: dictionary[kPublicationUniqueIdKey] as! Int)
        }
        
        //delete old
        let toDeletePredicate = NSPredicate(format: "NOT (uniqueId in %@)", argumentArray: [arrivedIds])
        let deleteFetchRequest   = NSFetchRequest(entityName: "Publication")
        deleteFetchRequest.predicate = toDeletePredicate
        
        localContext.performBlockAndWait { () -> Void in
            
            defer {
                
                do {
                    try localContext.save()

                } catch {
                    print("error deleting old publications \(error)" + __FUNCTION__)
                }
            }
            
            let publicationsToDelete = try! localContext.executeFetchRequest(deleteFetchRequest) as? [Publication]
            if let toDelete = publicationsToDelete {
                for publication in toDelete {
                    
                    //make delete notification object
                    let delete = ActivityLog.LogType.DeletePublication.rawValue
                    ActivityLog.activityLog(publication, type: delete, context: localContext)
                    localContext.deleteObject(publication)
                }
            }
        }
        
        
        //update existing
        let existingPredicate = NSPredicate(format: "uniqueId in %@", argumentArray: [arrivedIds])
        let existingFetchRequest   = NSFetchRequest(entityName: "Publication")
        existingFetchRequest.predicate = existingPredicate
        
        localContext.performBlockAndWait { () -> Void in
            
            defer {
                
                do {
                    try localContext.save()
                    
                } catch {
                    print("error deleting old publications \(error)" + __FUNCTION__)
                }
            }
            
            let existingPublications =  try! localContext.executeFetchRequest(existingFetchRequest) as? [Publication]
            if let toUpdate = existingPublications {
                
                for publication in toUpdate {
                    let dictionaries = results.filter {(dictionary) in
                        return dictionary[kPublicationUniqueIdKey] as? Int == publication.uniqueId?.integerValue}
                    
                    guard let dictionary = dictionaries.first else {continue}
                    
                    print("dictionary to update \(dictionary)")
                    publication.updateFromParams(dictionary)
                }
            }
        }
        
        //create new
        for dict in results {
            
            defer {
                
                do {
                    try localContext.save()
                    
                } catch {
                    print("error deleting old publications \(error)" + __FUNCTION__)
                }
            }
            
            guard let unique = dict[kPublicationUniqueIdKey] as? Int else {continue}
            let id =  NSNumber(integer: unique)
            //fetch with id
            let existingPredicate = NSPredicate(format: "uniqueId = %@", id)
            let existingFetchRequest   = NSFetchRequest(entityName: "Publication")
            existingFetchRequest.predicate = existingPredicate
            
            localContext.performBlockAndWait({ () -> Void in
                
                let existingPublications =  try! localContext.executeFetchRequest(existingFetchRequest) as? [Publication]
                if let founds = existingPublications {
                    
                    if founds.count == 0 {
                        
                        //create the new one
                        let publication = NSEntityDescription.insertNewObjectForEntityForName("Publication", inManagedObjectContext: localContext) as? Publication
                        if let newPublication = publication {
                            newPublication.updateFromParams(dict)
                            
                            //create notification object
                            let new = ActivityLog.LogType.NewPublication.rawValue
                            ActivityLog.activityLog(newPublication, type: new, context: localContext)
                        }
                    }
                }
            })
        }
        //fetch Reports
        
        let request = NSFetchRequest(entityName: "Publication")
        
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
                
                defer {
                    FCModel.sharedInstance.postReloadDataNotificationOnMainThread()
                }
                
                if let currentPublications = publications {
                    
                    for (publication) in currentPublications {
                        
                        let registrationFetcher = CDPublicationRegistrationFetcher(publication: publication, context: localContext)
                        registrationFetcher.fetchRegistrationsForPublication(true)
                    }
                }
            }
        
        //fetch groups
    }
    

}
