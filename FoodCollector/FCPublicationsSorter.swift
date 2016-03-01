//
//  FCPublicationsSorter.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/13/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

class FCPublicationsSorter: NSObject {
    
    class func sortPublicationsByDistanceFromUser(publications: [Publication]) -> [Publication] {
        
        var sortedPublications = publications

        sortedPublications.sortInPlace({ $0.distanceFromUserLocation < $1.distanceFromUserLocation })
        
        return sortedPublications
        
    }

    class func sortPublicationReportsByDate(publication: Publication) -> [PublicationReport]{
        let reports = publication.reports ?? Set<PublicationReport>()
        let reportsArray = Array(reports) as? [PublicationReport]
        guard var array = reportsArray else {return [PublicationReport]()}
        array = array.sort { $0.dateOfReport!.compare($1.dateOfReport!) == NSComparisonResult.OrderedDescending }
        return array
    }
    
    class func sortPublicationsByEndingDate(publications: [Publication]) -> [Publication] {
        
        var publicationsToSort = publications
        publicationsToSort.sortInPlace { $0.endingData!.compare($1.endingData!) == NSComparisonResult.OrderedAscending }
        return publicationsToSort
    }
    
    class func sortPublicationsByStartingDate(publications: [Publication]) -> [Publication] {
        var publicationsToSort = publications
        publicationsToSort = publicationsToSort.sort { $0.startingData!.compare($1.startingData!) == NSComparisonResult.OrderedDescending }
        return publicationsToSort
    }
    
    class func sortPublicationsByCountOfRegisteredUsers(publications: [Publication]) -> [Publication] {
        
        var publicationsToSort = publications
        publicationsToSort.sortInPlace({ $0.countOfRegisteredUsers < $1.countOfRegisteredUsers })
        return publicationsToSort
    }
    
    class func sortPublicationByIsOnAir(publications: [Publication]) -> [Publication] {
       
        var publicationsToSort = publications

        publicationsToSort = publicationsToSort.sort {(pub1 , pub2) in pub1.isOnAir!.boolValue.hashValue > pub2.isOnAir!.boolValue.hashValue }
        return publicationsToSort
    }

}
