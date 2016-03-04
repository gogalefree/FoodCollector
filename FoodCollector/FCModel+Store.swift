//
//  FCModel+Store.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

// MARK: - store

public extension FCModel {
    

    func loadPublications() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in

            let request = NSFetchRequest(entityName: "Publication")
            let predicate = NSPredicate(format: "startingData < %@ && endingData > %@ && isOnAir = %@", NSDate(), NSDate() , NSNumber(bool: true) )
            request.predicate = predicate
            let moc = FCModel.dataController.managedObjectContext
            moc.performBlock { () -> Void in
                
                do {
                    
                    let results = try moc.executeFetchRequest(request) as? [Publication]
                    if let currentPublications = results {
                        self.publications = currentPublications
                    }
                    
                    
                } catch {
                    print("error fetching publications in: " + __FUNCTION__ + "\nerror: \(error)")
                }
            }
        }
    }

    func loadUserCreatedPublications() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let request = NSFetchRequest(entityName: "Publication")
            let predicate = NSPredicate(format: "isUserCreatedPublication = %@", NSNumber(bool: true) )
            request.predicate = predicate
            let moc = FCModel.dataController.managedObjectContext
            moc.performBlock { () -> Void in
                
                do {
                    
                    let results = try moc.executeFetchRequest(request) as? [Publication]
                    if let publications = results { self.userCreatedPublications = publications}
                } catch {
                    print("error fetching publications in: " + __FUNCTION__ + "\nerror: \(error)")
                }

            }
        
        }
    }
}
