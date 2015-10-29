//
//  FetchedDataSorter.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/17/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import Foundation

public class FCFetchedDataSorter : NSObject {
    
    public class func publicationsToDelete(fetchedPublications: [FCPublication]) -> [FCPublication] {
        
        var publicationsToDelete = [FCPublication]()
        let currentPublications = FCModel.sharedInstance.publications

        for existingPublication in currentPublications {
                
                var shouldRemove = true
                for newPublication in fetchedPublications {
                    if existingPublication.uniqueId == newPublication.uniqueId && existingPublication.version == newPublication.version {
                        shouldRemove = false
                        break
                    }
                }
                if shouldRemove {
                    publicationsToDelete.append(existingPublication)
                }
            }

        print(__FUNCTION__ + " Publications To Delete: \(publicationsToDelete.count) ")
        return publicationsToDelete
    }
    
    public class func publicationToAdd(fetchedPublications: [FCPublication]) -> [FCPublication] {
        
        var toAdd = [FCPublication]()
        let currentPublications = FCModel.sharedInstance.publications
        
            for fetchedPublication in fetchedPublications {
                
                var shouldAdd = true
                
                for currentPublication in currentPublications {
                    if currentPublication.uniqueId == fetchedPublication.uniqueId && currentPublication.version == fetchedPublication.version {
                        shouldAdd = false
                        break
                    }
                }
                
                if shouldAdd {
                    toAdd.append(fetchedPublication)
                }
            }
        print(__FUNCTION__ + " Publications To Add Count: \(toAdd.count) ")
        return toAdd
    }
    
    public class func findPublicationToUpdate(publiationsToAdd: [FCPublication], presentedPublication: FCPublication) -> FCPublication? {
        
        var publicationToUpdate: FCPublication? = nil

        for aNewPublication in publiationsToAdd {
                
                if aNewPublication.uniqueId == presentedPublication.uniqueId && aNewPublication.version > presentedPublication.version {
                    publicationToUpdate = aNewPublication
                    break
                }
            }
        
        return publicationToUpdate
    }
    
    
}
