//
//  FetchedDataSorter.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/17/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import Foundation

public class FCFetchedDataSorter : NSObject {
    
    public class func publicationsToDelete(currentPublications: [FCPublication]) -> [FCPublication] {
        
        var publicationsToDelete = [FCPublication]()
        let theNewPublications = FCModel.sharedInstance.publications
        
        for publication in currentPublications {
            
            var shouldRemove = true
            for newPublication in theNewPublications {
             
                if publication.uniqueId == newPublication.uniqueId && publication.version == newPublication.version {
                    shouldRemove = false
                }
            }
            if shouldRemove {
                publicationsToDelete.append(publication)
            }
        }
        
        return publicationsToDelete
    }
    
    public class func publicationToAddAndUpdate(currentPublications: [FCPublication]) -> [FCPublication] {
        
            var toAdd = [FCPublication]()
            //var toUpdate: FCPublication = nil
            let theNewPublications = FCModel.sharedInstance.publications
            
            for aNewPublication in theNewPublications {
                
                var shouldUpdate = true
                var shouldAdd = true
                
                for currentPublication in currentPublications {
                    
                    if currentPublication.uniqueId == aNewPublication.uniqueId && currentPublication.version == aNewPublication.version {
                        shouldAdd = false
//                        break
                    }
                }
                
                if shouldAdd {
                    toAdd.append(aNewPublication)
                }
            }

        
        
        
        
        
        return toAdd
        
    }
    
    
    
}
