//
//  FCPublicationsSorter.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/13/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

class FCPublicationsSorter: NSObject {
    
    class func sortPublicationsByDistanceFromUser(publications: [FCPublication]) -> [FCPublication] {
        
        var sortedPublications = publications

        sortedPublications.sortInPlace({ $0.distanceFromUserLocation < $1.distanceFromUserLocation })
        
        return sortedPublications
        
    }

    class func sortPublicationReportsByDate(publication: FCPublication) {
        publication.reportsForPublication.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
    }
    
    class func sortPublicationsByEndingDate(publications: [FCPublication]) -> [FCPublication] {
        
        var publicationsToSort = publications
        publicationsToSort.sortInPlace({ $0.endingDate.compare($1.endingDate) == NSComparisonResult.OrderedAscending })
        
        for publication in publicationsToSort {
            print("\(publication.endingDate)")
        }
        return publicationsToSort
    }
    
    class func sortPublicationsByStartingDate(publications: [FCPublication]) -> [FCPublication] {
        var publicationsToSort = publications
        publicationsToSort.sortInPlace({ $0.startingDate.compare($1.startingDate) == NSComparisonResult.OrderedDescending })
        return publicationsToSort
    }
    
    class func sortPublicationsByCountOfRegisteredUsers(publications: [FCPublication]) -> [FCPublication] {
        var publicationsToSort = publications
        publicationsToSort.sortInPlace({ $0.countOfRegisteredUsers < $1.countOfRegisteredUsers })
        return publicationsToSort
    }
    
    class func sortPublicationByIsOnAir(publications: [FCPublication]) -> [FCPublication] {
       
        var publicationsToSort = publications

        publicationsToSort.sortInPlace({ $0.isOnAir != $1.isOnAir})
        publicationsToSort.sortInPlace({ $0.isOnAir == $1.isOnAir && $0.endingDate.compare($1.endingDate) == NSComparisonResult.OrderedDescending })
        return publicationsToSort
    }
    
    class func sortPublicationsByIsOffAir(publications: [FCPublication]) -> [FCPublication] {
        
        var publicationsToSort = publications
        publicationsToSort.sortInPlace({ $0.isOnAir != $1.isOnAir})
        return publicationsToSort
    }


}
